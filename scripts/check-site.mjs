import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {JSDOM} from 'jsdom';
const root=path.resolve('.site');const base=process.env.SITE_BASE??'/employee-agent-platform-docs/';
const walk=dir=>fs.readdirSync(dir,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(path.join(dir,e.name)):[path.join(dir,e.name)]);
const htmlFiles=walk(root).filter(f=>f.endsWith('.html'));const documents=new Map(htmlFiles.map(f=>[f,new JSDOM(fs.readFileSync(f,'utf8')).window.document]));
let links=0,diagrams=0;const errors=[];
for(const [file,doc] of documents){const relative=path.relative(root,file);for(const el of doc.querySelectorAll('[href],[src]')){const raw=el.getAttribute('href')??el.getAttribute('src');if(/^[a-z][a-z\d+.-]*:/i.test(raw)||raw.startsWith('//'))continue;links++;const url=new URL(raw,'https://agents-foundry.github.io'+base+relative.replaceAll('\\','/'));if(!url.pathname.startsWith(base)){errors.push(`${relative}: URL misses Pages base path: ${raw}`);continue;}let target=path.join(root,decodeURIComponent(url.pathname.slice(base.length)));if(fs.existsSync(target)&&fs.statSync(target).isDirectory())target=path.join(target,'index.html');if(!fs.existsSync(target)){errors.push(`${relative}: missing resource ${raw}`);continue;}if(url.hash&&documents.has(target)&&!documents.get(target).getElementById(decodeURIComponent(url.hash.slice(1))))errors.push(`${relative}: missing anchor ${raw}`);}
const ids=[...doc.querySelectorAll('[id]')].map(el=>el.id);if(new Set(ids).size!==ids.length)errors.push(`${relative}: duplicate element IDs`);if(!doc.querySelector('h1'))errors.push(`${relative}: missing primary heading`);diagrams+=doc.querySelectorAll('.mermaid[data-source]').length;
}
const index=JSON.parse(fs.readFileSync(path.join(root,'assets/search-index.json'),'utf8'));assert.equal(index.length,htmlFiles.length-1,'Every article is searchable; 404 is excluded');
for(const page of index){assert(page.title&&page.text&&page.url.startsWith(base),'Complete search entry');assert(fs.existsSync(path.join(root,page.url.slice(base.length))),'Search result points to a generated article');}
// Every static Mermaid module import must be part of the locally hosted asset tree.
for(const file of walk(path.join(root,'assets/mermaid')).filter(f=>f.endsWith('.mjs'))){const text=fs.readFileSync(file,'utf8');for(const m of text.matchAll(/(?:from\s*|import\s*\()?['"](\.\.?\/[^'"]+\.mjs)['"]/g))if(!fs.existsSync(path.resolve(path.dirname(file),m[1])))errors.push(`Missing Mermaid module: ${m[1]}`);}
const result={pages:index.length,htmlFiles:htmlFiles.length,links,diagrams,errors};fs.mkdirSync('.validation',{recursive:true});fs.writeFileSync('.validation/site-report.json',JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result,null,2));if(errors.length)process.exitCode=1;
