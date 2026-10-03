import fs from 'node:fs';
import path from 'node:path';
import { createHash } from 'node:crypto';
import ts from 'typescript';
import { pathToFileURL } from 'node:url';

const root = process.cwd();
const source = path.resolve(process.argv[2] ?? '.sources/platform');
const sha = '9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4';
const base = `https://github.com/Agents-Foundry/employee-agent-platform/blob/${sha}/`;
const walk = (dir) => fs.readdirSync(dir, { withFileTypes: true }).flatMap(e => e.isDirectory() ? walk(path.join(dir,e.name)) : [path.join(dir,e.name)]);
const rel = p => path.relative(source,p).replaceAll('\\','/');
const files = walk(source).filter(p=>!p.includes(`${path.sep}.git${path.sep}`));
const textFiles = files.filter(p=>/\.(ts|json|md|ya?ml|mjs|mts|rs|toml|html|scss|css)$/.test(p)||path.basename(p)==='.env.example'||p.endsWith('Dockerfile'));
const inventory = Object.fromEntries(textFiles.map(p=>[rel(p),createHash('sha256').update(fs.readFileSync(p,'utf8').replaceAll('\r\n','\n')).digest('hex')]));
const write=(p,s)=>{fs.mkdirSync(path.dirname(p),{recursive:true});fs.writeFileSync(p,s.trim()+'\n');};
write('source-inventory.json',JSON.stringify({schemaVersion:1,repository:'Agents-Foundry/employee-agent-platform',commit:sha,inspectedDate:'2026-10-03',files:inventory},null,2));
const trees = textFiles.filter(p=>p.endsWith('.ts')).map(p=>({file:rel(p),tree:ts.createSourceFile(rel(p),fs.readFileSync(p,'utf8'),ts.ScriptTarget.Latest,true)}));
const constants=new Map();
function unwrap(n){while(n&&(ts.isAsExpression(n)||ts.isParenthesizedExpression(n)||ts.isSatisfiesExpression(n)))n=n.expression;return n;}
for(const {tree} of trees){const visit=n=>{if(ts.isVariableDeclaration(n)&&ts.isIdentifier(n.name)&&n.initializer)constants.set(n.name.text,unwrap(n.initializer));ts.forEachChild(n,visit);};visit(tree);}
function val(n,depth=0){n=unwrap(n);if(!n||depth>6)return null;if(ts.isStringLiteralLike(n))return n.text;if(ts.isIdentifier(n))return val(constants.get(n.text),depth+1);if(ts.isPropertyAccessExpression(n)){const obj=unwrap(constants.get(n.expression.getText()));if(obj&&ts.isObjectLiteralExpression(obj)){const prop=obj.properties.find(p=>p.name?.getText().replaceAll(/["']/g,'')===n.name.text);return prop&&ts.isPropertyAssignment(prop)?val(prop.initializer,depth+1):null;}}if(ts.isCallExpression(n)&&n.expression.getText()==='relative'){const p=val(n.arguments[0],depth+1);return p?.startsWith('/runtime/v1')?p.slice('/runtime/v1'.length):null;}if(ts.isTemplateExpression(n)){let out=n.head.text;for(const span of n.templateSpans){const p=val(span.expression,depth+1);if(p===null)return null;out+=p+span.literal.text;}return out;}return null;}
const routes=[];const unresolved=[];
for(const {file,tree} of trees.filter(x=>x.file.startsWith('apps/control-plane-api/src/'))){
 const calls=[];const routers=new Map([['app','']]);
 const visit=n=>{if(ts.isCallExpression(n)&&ts.isPropertyAccessExpression(n.expression))calls.push(n);ts.forEachChild(n,visit);};visit(tree);
 for(const n of calls){if(n.expression.name.text==='use'&&n.expression.expression.getText()==='app'&&n.arguments.length>=2){const prefix=val(n.arguments[0]);const name=n.arguments.at(-1).getText();if(prefix&&ts.isIdentifier(n.arguments.at(-1)))routers.set(name,prefix);}}
 for(const n of calls){const method=n.expression.name.text.toUpperCase();const object=n.expression.expression.getText();if(!['GET','POST','PUT','PATCH','DELETE'].includes(method)||!routers.has(object))continue;
  const paths=ts.isArrayLiteralExpression(n.arguments[0])?n.arguments[0].elements.map(x=>val(x)):[val(n.arguments[0])];
  if(paths.some(x=>x===null)){unresolved.push({file,line:tree.getLineAndCharacterOfPosition(n.getStart()).line+1,expression:n.arguments[0]?.getText()});continue;}
  for(const p of paths){
  const route=(routers.get(object)+p).replace(/\/$/,'')||'/';
  const handler=n.arguments.slice(1).find(a=>ts.isArrowFunction(a)||ts.isFunctionExpression(a));
  const body=handler?.getText(tree)||'';const line=tree.getLineAndCharacterOfPosition(n.getStart()).line+1;
  let group=route.startsWith('/runtime/')?'runtime':route.startsWith('/api/execution/')?'execution':route.startsWith('/api/auth/')?'authentication':route.includes('catalog')||route.includes('agent-installations')?'catalog':route.includes('model-')||route.includes('alert-webhooks')?'models-and-alerts':route.includes('connector')||route.includes('action-polic')||route.includes('reconciliation')||route.includes('source-control')||route.includes('credential-leases')?'governance-and-connections':route.includes('organization')?'organization':'agents-and-conversations';
  const middleware=n.arguments.slice(1).filter(a=>!ts.isArrowFunction(a)&&!ts.isFunctionExpression(a)).map(a=>a.getText());
  let access=route.startsWith('/runtime/')?(body.includes('authenticateExecution')?'Execution workload signature':'Agent workload signature'):file.endsWith('/auth.ts')?'Authentication lifecycle; per-route guards':file.endsWith('/metrics-route.ts')?'Operator bearer token; conditional route':route==='/api/health'?'Public liveness':'Authenticated actor; service ownership/role checks';
  if(route.includes('/organization/'))access='Password-mode organization admin; service authorization';
  const status=[...new Set([...body.matchAll(/\.status\((\d+)\)/g)].map(m=>m[1]))];
  const errors=[...new Set([...body.matchAll(/(?:error:\s*|(?:ExecutionError|OrganizationDomainError)\(\d+,\s*)['"]([A-Z][A-Z0-9_]+)['"]/g)].map(m=>m[1]))];
  const bindings=[...new Set([...body.matchAll(/(?:\w+\.)?(\w+)\.(?:parse|safeParse)\(([^)]*)\)/g)].map(m=>`${m[1]}(${m[2]})`))];
  routes.push({method,path:route,file,line,group,access,middleware,status,errors,bindings,handler:body});
  }
 }
}
if(unresolved.length)throw new Error('Unresolved route registration: '+JSON.stringify(unresolved));
// Execution server uses node:http rather than Express registrations.
routes.push({method:'GET',path:'/execution/v1/health',file:'apps/execution-runtime/src/server.ts',line:1,group:'execution-server',access:'Private service network; public health within that boundary',middleware:[],status:['200'],errors:[],bindings:[],handler:'Health returns { status, provider, isolation, enforces }.'});
routes.push({method:'POST',path:'/execution/v1/operations',file:'apps/execution-runtime/src/server.ts',line:1,group:'execution-server',access:'Control-plane-signed single-use grant; private service network',middleware:[],status:['200','400','413','415'],errors:['REQUEST_INVALID','REQUEST_TOO_LARGE','JSON_REQUIRED','EXECUTION_RUNTIME_ERROR'],bindings:['parseExecutionRequest'],handler:"Request: { protocol: 'agents-foundry/execution/v1', grant, operation }. Response: ExecuteOperationResponse; result.status is SUCCEEDED | FAILED | TIMED_OUT | DENIED. HTTP 200 does not imply operation success."});
routes.push({method:'GET',path:'/metrics',file:'apps/execution-runtime/src/server.ts',line:1,group:'execution-server',access:'Operator bearer token; conditional route',middleware:[],status:['200','401'],errors:[],bindings:[],handler:'Exists only with execution metrics configuration. Response is Prometheus text, not JSON.'});
routes.sort((a,b)=>a.group.localeCompare(b.group)||a.path.localeCompare(b.path)||a.method.localeCompare(b.method));
write('reference-data/routes.json',JSON.stringify(routes,null,2));
for(const group of new Set(routes.map(r=>r.group))){const rs=routes.filter(r=>r.group===group);let s=`# ${group.replaceAll('-',' ')} API\n\n**Audience:** API consumers and developers. **Implementation status:** Implemented (subject to route guards and feature flags).\n\n**Prerequisites:** Read [HTTP conventions](README.md), sign in for browser API calls, or configure the signed workload identity for runtime calls.\n\nThis reference is extracted from route registrations at \`${sha}\`. Handler bindings below identify actual input validators, service calls and response expressions; referenced service schemas supply the full field bounds. Authentication middleware and service authorization still apply. See [request validators](request-schemas.md) and [wire contracts](contracts.md).\n\n## Endpoints\n\n| Method | Path | Access | Source |\n| --- | --- | --- | --- |\n`;
 for(const r of rs)s+=`| ${r.method} | \`${r.path}\` | ${r.access} | [handler](${base+r.file}#L${r.line}) |\n`;
 for(const [i,r] of rs.entries()){s+=`\n## ${r.method} ${r.path}\n\n- **Authorization:** ${r.access}${r.middleware.length?'; route middleware: '+r.middleware.map(x=>'`'+x+'`').join(', '):''}.\n- **Parameters:** ${[...r.path.matchAll(/:([A-Za-z]\w*)/g)].map(m=>'`'+m[1]+'`').join(', ')||'No path parameters'}; body/query bindings are shown below.\n- **Explicit handler HTTP statuses:** ${r.status.join(', ')||'200 on normal JSON response'}; shared middleware/service errors also apply.\n- **Handler-local error codes:** ${r.errors.map(x=>'`'+x+'`').join(', ')||'No additional literal error code in this handler; consult service and common errors'}.\n- **Input validators:** ${r.bindings.map(x=>'`'+x.replaceAll('|','\\|')+'`').join(', ')||'Service validation or route has no parsed body/query'}.\n\n`;
 const body=r.handler.split('\n');
 if(body.length<=60)s+='Request/response implementation binding (TypeScript, not a copyable HTTP command):\n\n```typescript\n'+r.handler+'\n```\n';
 else s+='The complete login/transaction handler is intentionally linked rather than excerpted incompletely: [request, response and branch guards]('+base+r.file+'#L'+r.line+').\n';
 s+=`\n[Source handler](${base+r.file}#L${r.line}).\n`;
 }
 s+='\n## Related documentation\n\n[HTTP conventions](README.md) · [Request schemas](request-schemas.md) · [Wire contracts](contracts.md) · [Source inventory](../reference/provenance.md)\n';write(`docs/api/${group}.md`,s);
}
const schemaBlocks=[];const contractBlocks=[];
for(const {file,tree} of trees.filter(x=>x.file.startsWith('apps/')&&x.file.includes('/src/')||x.file.startsWith('packages/contracts/src/'))){
 const visit=n=>{
  if(ts.isVariableDeclaration(n)&&n.initializer&&/\bz\./.test(n.initializer.getText()))schemaBlocks.push({file,name:n.name.getText(),line:tree.getLineAndCharacterOfPosition(n.getStart()).line+1,body:n.initializer.getText()});
  if(file.startsWith('packages/contracts/src/')&&(ts.isInterfaceDeclaration(n)||ts.isTypeAliasDeclaration(n))&&n.modifiers?.some(m=>m.kind===ts.SyntaxKind.ExportKeyword))contractBlocks.push({file,name:n.name.getText(),line:tree.getLineAndCharacterOfPosition(n.getStart()).line+1,body:n.getText()});
  ts.forEachChild(n,visit);
 };visit(tree);
}
const refPage=(title,items)=>`# ${title}\n\n**Audience:** Developers and API consumers. **Implementation status:** Implemented contracts; availability of execution depends on the implementation matrix.\n\n**Prerequisites:** Read the [HTTP conventions](README.md) and relevant endpoint page.\n\nExtracted at \`${sha}\`. These are literal source declarations, not evidence that a corresponding engine exists. Schemas express required fields, defaults, enum values, refinements and unknown-field rejection. Type-only structures still require runtime validation and authorization.\n\n`+items.map((x,i)=>`## ${x.name} (${i+1})\n\n[Source](${base+x.file}#L${x.line}).\n\n\`\`\`typescript\n${x.body}\n\`\`\`\n`).join('\n')+'\n## Related documentation\n\n[API index](README.md) · [Implementation status](../reference/implementation-status.md)\n';
write('docs/api/request-schemas.md',refPage('Request and protocol validation schemas',schemaBlocks));
write('docs/api/contracts.md',refPage('Wire and domain contract reference',contractBlocks));
const tests=files.filter(p=>/\.(spec|live)\.ts$/.test(p));
write('docs/reference/tests.md',`# Test evidence inventory\n\n**Audience:** QA and developers. **Implementation status:** Implemented suites, not a claim that they ran in this documentation task.\n\n**Prerequisites:** [Developer setup](../developer/local-development.md).\n\nInventory at \`${sha}\`. Titles are source evidence; execution results belong in CI/readiness artifacts.\n\n| Test file | Test declarations (static count) |\n| --- | --- |\n`+tests.map(p=>`| [${rel(p)}](${base+rel(p)}) | ${[...fs.readFileSync(p,'utf8').matchAll(/\b(?:it|test)(?:\.\w+)?\s*\(/g)].length} |`).join('\n')+'\n\n[QA strategy](../qa/test-strategy.md) · [Pilot readiness](../qa/pilot-readiness.md)\n');
const env=new Map();
for(const p of textFiles.filter(p=>/\.(ts|mjs)$/.test(p))){const s=fs.readFileSync(p,'utf8');for(const m of s.matchAll(/(?:process\.env|\benv)\[['"]([A-Z][A-Z0-9_]+)['"]\]/g)){if(!env.has(m[1]))env.set(m[1],new Set());env.get(m[1]).add(rel(p));}}
write('docs/reference/environment-inventory.md',`# Environment variable source inventory\n\n**Audience:** Operators and developers. **Implementation status:** Implemented source reads.\n\n**Prerequisites:** [Configuration guide](configuration.md).\n\nThis complete static inventory lists direct process/env reads, including test/evaluation knobs. Required helpers and computed provider key names are described in the configuration guide; do not treat every row as a required production variable.\n\n| Name | Source reads |\n| --- | --- |\n`+[...env.entries()].sort().map(([name,paths])=>`| \`${name}\` | ${[...paths].map(p=>`[${p}](${base+p})`).join(', ')} |`).join('\n')+'\n\n[Configuration guide](configuration.md) · [Source baseline](provenance.md)\n');
console.log(JSON.stringify({sourceFiles:Object.keys(inventory).length,routes:routes.length,schemas:schemaBlocks.length,contracts:contractBlocks.length,testFiles:tests.length,environmentVariables:env.size}));
