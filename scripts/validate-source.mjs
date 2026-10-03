import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { createHash } from 'node:crypto';
import assert from 'node:assert/strict';
import ts from 'typescript';
import {z} from 'zod';

const source=path.resolve(process.argv[2]??'.sources/platform');
const inventory=JSON.parse(fs.readFileSync('source-inventory.json','utf8'));
const productLock=JSON.parse(fs.readFileSync(path.join(source,'package-lock.json'),'utf8'));
const installedZod=JSON.parse(fs.readFileSync('node_modules/zod/package.json','utf8'));
assert.equal(installedZod.version,productLock.packages['node_modules/zod'].version,'Use the product baseline runtime validator version');
const load=async p=>import(pathToFileURL(path.join(source,p)).href);
let checked=0;
for(const [p,hash] of Object.entries(inventory.files)){
 const file=path.join(source,p);
 assert(fs.existsSync(file),`Missing pinned source: ${p}`);
 assert.equal(createHash('sha256').update(fs.readFileSync(file,'utf8').replaceAll('\r\n','\n')).digest('hex'),hash,`Source drift: ${p}`);
 checked++;
}
const {manifestV2PayloadSchema,parseSignedManifest,taskSpecSchema,parseRuntimeCommand,parseRuntimeEvent,parseRuntimeActionRequest}=await load('packages/contracts/src/runtime/v1/schemas.ts');
const {ManifestVerifier}=await load('apps/agent-runtime/src/manifest-verifier.ts');
const {canonicalManifest}=await load('packages/contracts/src/manifest.ts');
const {resolveCatalog}=await load('apps/control-plane-api/src/catalog/catalog-registry.ts');
const {builtInCatalog}=await load('packages/catalog/src/index.ts');
const {isKnownAction,evaluatePolicy}=await load('packages/policy-engine/src/index.ts');
const {buildManifestV2}=await load('apps/control-plane-api/src/agents/manifest-v2.ts');
const payload=JSON.parse(fs.readFileSync('examples/manifest-v2/qa-agent.payload.json','utf8'));
const signed=JSON.parse(fs.readFileSync('examples/manifest-v2/qa-agent.signed.json','utf8'));
const key=JSON.parse(fs.readFileSync('examples/manifest-v2/verification-key.json','utf8'));
const command=JSON.parse(fs.readFileSync('examples/runtime/run-submit.json','utf8'));
manifestV2PayloadSchema.parse(payload);parseSignedManifest(signed);parseRuntimeCommand(command);
assert.deepEqual(signed.payload,payload);
new ManifestVerifier(key.publicKeySpki).verify(signed,{correlation:command.correlation,runtimeProfile:payload.runtime.profile});
const bundle=resolveCatalog(builtInCatalog,isKnownAction).find(b=>b.content.blueprint.id===payload.metadata.blueprint.id&&b.content.blueprint.version===payload.metadata.blueprint.version);
assert(bundle,'Example blueprint version is registered');assert.equal(bundle.digest,payload.metadata.blueprint.digest);
const resolved=buildManifestV2({manifestId:payload.metadata.manifestId,agentId:payload.metadata.agentId,organizationId:payload.metadata.organizationId,employeeId:payload.metadata.employeeId,issuedAt:payload.metadata.issuedAt,agentName:payload.identity.name,bundle:{...bundle.content,digest:bundle.digest},installationId:payload.metadata.installationId??null,provider:payload.model.provider,model:payload.model.model,credentialMode:payload.model.credentialMode,answers:payload.configuration,capabilities:bundle.content.blueprint.policy.actions.map(action=>({action,outcome:evaluatePolicy(action).outcome}))});
assert.equal(canonicalManifest(resolved),canonicalManifest(payload),'Example matches actual resolver and policy');
// The browser schema is local to its route module. Extract its actual AST initializer
// rather than importing Express/PostgreSQL or maintaining a look-alike validator.
const startSource=fs.readFileSync(path.join(source,'apps/control-plane-api/src/execution/execution-routes.ts'),'utf8');
const startTree=ts.createSourceFile('execution-routes.ts',startSource,ts.ScriptTarget.Latest,true);
let startExpression;
const visitStart=n=>{if(ts.isVariableDeclaration(n)&&n.name.getText()==='startRunSchema')startExpression=n.initializer.getText(startTree);ts.forEachChild(n,visitStart);};visitStart(startTree);
assert(startExpression,'Actual browser schema must be present');
const startSchema=Function('z','taskSpecSchema',`return (${startExpression});`)(z,taskSpecSchema);
const startInput=JSON.parse(fs.readFileSync('examples/api/start-run.json','utf8'));
startSchema.parse(startInput);
assert.throws(()=>startSchema.parse({...startInput,organizationId:'forged'}),'Browser start schema must reject caller-supplied tenant');
function initializer(file,name){const tree=ts.createSourceFile(file,fs.readFileSync(path.join(source,file),'utf8'),ts.ScriptTarget.Latest,true);let expression;const visit=n=>{if(ts.isVariableDeclaration(n)&&n.name.getText()===name)expression=n.initializer;ts.forEachChild(n,visit);};visit(tree);assert(expression,`Missing source validator ${file}:${name}`);return expression;}
const member=initializer('apps/control-plane-api/src/organization-routes.ts','memberInput');
const memberSchema=Function('z',`return (${member.getText()});`)(z);
const customer=initializer('apps/control-plane-api/src/create-customer.ts','input');
assert(ts.isCallExpression(customer)&&ts.isPropertyAccessExpression(customer.expression)&&customer.expression.name.text==='parse');
const customerSchema=Function('z','memberInput',`return (${customer.expression.expression.getText()});`)(z,memberSchema);
const customerExample=fs.readFileSync('docs/admin/customer-onboarding.md','utf8').match(/```json\r?\n([\s\S]*?)```/);
assert(customerExample,'Customer guide has its complete sanitized input');customerSchema.parse(JSON.parse(customerExample[1]));
parseRuntimeEvent(JSON.parse(fs.readFileSync('examples/runtime/run-started.json','utf8')));
const action=JSON.parse(fs.readFileSync('examples/runtime/action-request.json','utf8'));
parseRuntimeActionRequest(action);
const {IssueTrackerTool}=await load('apps/agent-runtime/src/tools/issue-tracker-tool.ts');
const {controlPlaneAction}=await load('apps/control-plane-api/src/actions/action-registry.ts');
new IssueTrackerTool().parse(action.parameters);
controlPlaneAction(action.action).parameters.parse(action.parameters);
assert.equal(createHash('sha256').update(canonicalManifest(action.parameters)).digest('hex'),action.inputDigest);
const changed=structuredClone(signed);changed.payload.identity.name='Changed';
assert.throws(()=>new ManifestVerifier(key.publicKeySpki).verify(changed,{correlation:command.correlation,runtimeProfile:payload.runtime.profile}),'Tampered signature must fail');
assert.throws(()=>manifestV2PayloadSchema.parse({...payload,unexpected:true}),'Unknown manifest fields must fail');
const productScripts=JSON.parse(fs.readFileSync(path.join(source,'package.json'),'utf8')).scripts;
const docsScripts=JSON.parse(fs.readFileSync('package.json','utf8')).scripts;
const knownScripts=new Set([...Object.keys(productScripts),...Object.keys(docsScripts)]);
const workspaceScripts=new Set(['control-plane-api','agent-runtime','execution-runtime'].flatMap(name=>Object.keys(JSON.parse(fs.readFileSync(path.join(source,'apps',name,'package.json'),'utf8')).scripts)));
const walk=dir=>fs.readdirSync(dir,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(path.join(dir,e.name)):[path.join(dir,e.name)]);
let commandReferences=0;
for(const file of [...walk('docs'),...walk('examples'),'README.md','CONTRIBUTING.md'].filter(f=>f.endsWith('.md'))){const text=fs.readFileSync(file,'utf8');for(const m of text.matchAll(/npm run ([\w:-]+)/g)){const workspaceOnly=workspaceScripts.has(m[1])&&(text.slice(m.index,m.index+200).includes('--workspace')||(file.replaceAll('\\','/').startsWith('docs/adr/')&&text.includes('Current command correction')));assert(knownScripts.has(m[1])||workspaceOnly,`Undocumented/invented root command ${m[1]} in ${file}`);commandReferences++;}}
const checks={sourceFiles:checked,catalogBundles:resolveCatalog(builtInCatalog,isKnownAction).length,examples:7,inlineExamples:1,negativeChecks:3,commandReferences};
fs.mkdirSync('.validation',{recursive:true});fs.writeFileSync('.validation/source-report.json',JSON.stringify(checks,null,2)+'\n');
console.log(JSON.stringify(checks));
