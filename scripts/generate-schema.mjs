import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
const source=path.resolve(process.argv[2]??'.sources/platform');
const sha='9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4';
const base=`https://github.com/Agents-Foundry/employee-agent-platform/blob/${sha}/`;
const folder='apps/control-plane-api/src/db/migrations';
const migrations=[];
for(const file of fs.readdirSync(path.join(source,folder)).filter(f=>f.endsWith('.ts')).sort()){
 const module=await import(pathToFileURL(path.join(source,folder,file)).href);
 const sql=Object.values(module).find(x=>typeof x==='string');
 if(typeof sql!=='string')throw new Error(`No SQL export: ${file}`);
 migrations.push({file:`${folder}/${file}`,sql});
}
function splitTop(s){let depth=0,quote=false,start=0,out=[];for(let i=0;i<s.length;i++){if(s[i]==="'"){if(quote&&s[i+1]==="'"){i++;continue;}quote=!quote;}if(quote)continue;if(s[i]==='(')depth++;if(s[i]===')')depth--;if(s[i]===','&&depth===0){out.push(s.slice(start,i).trim());start=i+1;}}out.push(s.slice(start).trim());return out;}
const tables=new Map();
for(const m of migrations){for(const match of m.sql.matchAll(/CREATE TABLE\s+(\w+)\s*\(/g)){let depth=1,i=match.index+match[0].length,quote=false,start=i;for(;i<m.sql.length;i++){if(m.sql[i]==="'"){if(quote&&m.sql[i+1]==="'"){i++;continue;}quote=!quote;}if(quote)continue;if(m.sql[i]==='(')depth++;if(m.sql[i]===')'&&--depth===0)break;}
 const parts=splitTop(m.sql.slice(start,i));const columns=[],constraints=[];
 for(const p of parts){const c=/^(\w+)\s+(text|bigint|integer|smallint|double\s+precision|timestamptz|jsonb|boolean|bytea)\b([\s\S]*)$/i.exec(p);if(c)columns.push({name:c[1],type:c[2],definition:c[3].trim()});else if(/^(PRIMARY|FOREIGN|UNIQUE|CHECK|CONSTRAINT)\b/i.test(p))constraints.push(p);else throw Error(`Unrecognized SQL field/constraint in ${match[1]}: ${p}`);}
 tables.set(match[1],{file:m.file,columns,constraints});
 }
 // Registry SQL already expands the native type-conversion maps.
 for(const match of m.sql.matchAll(/ALTER TABLE\s+(\w+)\s+([\s\S]*?);/g)){
  const table=tables.get(match[1]);if(!table)continue;
  for(const clause of splitTop(match[2])){
   const type=/ALTER COLUMN (\w+) TYPE (\w+)/.exec(clause);if(type){const c=table.columns.find(c=>c.name===type[1]);if(c)c.type=type[2];}
   const add=/ADD COLUMN (\w+)\s+(text|integer|bigint|smallint|double\s+precision|timestamptz|jsonb|boolean)\b([\s\S]*)/.exec(clause);if(add)table.columns.push({name:add[1],type:add[2],definition:add[3].trim()});
  }
 }
}
const write=(p,s)=>{fs.mkdirSync(path.dirname(p),{recursive:true});fs.writeFileSync(p,s.trim()+'\n');};
// Migration 0008 removes text JSON-validity CHECKs before converting to jsonb.
// Remove only those checks, preserving unrelated constraints. The exact SQL still
// carries dynamic policy/trigger behavior that this static dictionary does not execute.
function removeJsonChecks(definition){let out='',cursor=0;for(const m of definition.matchAll(/CHECK\s*\(/gi)){if(m.index<cursor)continue;let depth=1,i=m.index+m[0].length;for(;i<definition.length;i++){if(definition[i]==='(')depth++;if(definition[i]===')'&&--depth===0){i++;break;}}const check=definition.slice(m.index,i);if(check.includes('af_json_valid(')){out+=definition.slice(cursor,m.index);cursor=i;}}return (out+definition.slice(cursor)).trim();}
for(const t of tables.values())for(const c of t.columns)if(c.type==='jsonb')c.definition=removeJsonChecks(c.definition);
const detail=tables.get('agent_run_steps')?.columns.find(c=>c.name==='detail');if(detail)detail.definition=detail.definition.replace(/DEFAULT\s+'\{\}'(?:\:\:jsonb)?/g,"DEFAULT '{}'::jsonb");
write('reference-data/schema.json',JSON.stringify({commit:sha,migrations:migrations.map(m=>m.file),tables:Object.fromEntries(tables)},null,2));
write('reference-data/postgresql-migrations.sql',migrations.map(m=>`-- SOURCE: ${m.file}\n${m.sql}`).join('\n\n'));
let s=`# PostgreSQL schema and constraints\n\n**Audience:** Backend developers, architects and database operators. **Implementation status:** Implemented, source-derived schema.\n\n**Prerequisites:** Read [data ownership and migrations](README.md).\n\nThe current control plane uses PostgreSQL, with 15 registered migrations. This dictionary extracts CREATE TABLE fields plus explicit ADD COLUMN and TYPE changes from actual exported migration SQL. Native conversion migration 0008 changes many ISO timestamp/JSON text fields to timestamptz/jsonb; signed or digest-pinned text remains text. This is a static reference, not a live database introspection result. No RLS policy or trigger is inferred from a TypeScript interface. Consult linked migration SQL for complete check/trigger/grant semantics.\n\n[Exact combined migration SQL](../../reference-data/postgresql-migrations.sql) · [Machine-readable dictionary](../../reference-data/schema.json). Do not run the combined file instead of the checksum-locked migration tool.\n\n## Tables\n\n| Table | Ownership | Source |\n| --- | --- | --- |\n`;
for(const [name,t] of tables)s+=`| [${name}](#${name}) | ${t.columns.some(c=>c.name==='organization_id')?'Tenant ID on row; verify FORCE RLS in migration':'Global/auth/catalog or special-scope table; inspect grants/policy'} | [migration](${base+t.file}) |\n`;
for(const [name,t] of tables){s+=`\n## ${name}\n\n[Defining migration](${base+t.file}).\n\n| Field | Current declared type | Declaration / constraint |\n| --- | --- | --- |\n`;
 for(const c of t.columns)s+=`| \`${c.name}\` | \`${c.type}\` | \`${c.definition.replaceAll(/\s+/g,' ').replaceAll('|','\\|')}\` |\n`;
 if(t.constraints.length)s+='\nTable-level keys/checks/relationships from the CREATE statement:\n\n```sql\n'+t.constraints.join(',\n')+'\n```\n';
 const indexes=migrations.flatMap(m=>[...m.sql.matchAll(/CREATE (?:UNIQUE )?INDEX[\s\S]*?;/g)].map(x=>x[0])).filter(x=>new RegExp(`\\bON\\s+${name}\\b`,'i').test(x));
 if(indexes.length)s+='\nIndexes (including partial/case-insensitive uniqueness):\n\n```sql\n'+indexes.join('\n')+'\n```\n';
}
s+='\n## Migration ledger\n\n`schema_migrations` is created by `db/migrate.ts`, outside the baseline table SQL: version, name, checksum and applied_at. It records the checksum-normalized ordered migration history.\n\n## Related documentation\n\n[Domain ownership](../architecture/domain-model.md) · [Authorization](../security/authorization.md) · [Migration procedures](README.md)\n';write('docs/data-model/schema.md',s);
console.log(JSON.stringify({migrations:migrations.length,tables:tables.size,fields:[...tables.values()].reduce((n,t)=>n+t.columns.length,0)}));
