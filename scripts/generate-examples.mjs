import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { createHash } from 'node:crypto';
const source=path.resolve(process.argv[2]??'.sources/platform');
const load=async p=>import(pathToFileURL(path.join(source,p)).href);
const {builtInCatalog}=await load('packages/catalog/src/index.ts');
const {resolveCatalog}=await load('apps/control-plane-api/src/catalog/catalog-registry.ts');
const {isKnownAction,evaluatePolicy}=await load('packages/policy-engine/src/index.ts');
const {buildManifestV2}=await load('apps/control-plane-api/src/agents/manifest-v2.ts');
const {ManifestSigner}=await load('apps/control-plane-api/src/manifest-signing.ts');
const {canonicalManifest}=await load('packages/contracts/src/manifest.ts');
const b=resolveCatalog(builtInCatalog,isKnownAction).find(b=>b.content.blueprint.id==='engineering.qa-engineer'&&b.content.blueprint.version==='1.2.0');
const answers={projectName:'Example checkout',repositoryUrl:'https://github.com/example-org/example-app',qaUrl:'https://qa.example.com',issueTracker:['Jira'],sourceControl:['GitHub'],testingTechnologies:['Playwright'],projectScripts:'test,build',packageRegistryUrl:'https://registry.npmjs.org'};
// Keep only the exact questionnaire fields; all values are fictional and contain no credential.
const configuration=Object.fromEntries(Object.entries(answers).filter(([k])=>b.content.blueprint.questionnaire.some(q=>q.id===k)));
const payload=buildManifestV2({manifestId:'10000000-0000-4000-8000-000000000001',agentId:'agent_example_qa',organizationId:'org_example',employeeId:'employee_example',issuedAt:'2026-10-07T09:00:00Z',agentName:'Example QA Employee',bundle:{...b.content,digest:b.digest},installationId:'10000000-0000-4000-8000-000000000002',provider:'anthropic',model:'example-model-id',credentialMode:'ORGANIZATION_MANAGED',answers:configuration,capabilities:b.content.blueprint.policy.actions.map(action=>({action,outcome:evaluatePolicy(action).outcome}))});
const signer=new ManifestSigner();const signed=signer.sign(payload);
const write=(p,obj)=>{fs.mkdirSync(path.dirname(p),{recursive:true});fs.writeFileSync(p,JSON.stringify(obj,null,2)+'\n');};
write('examples/manifest-v2/qa-agent.payload.json',payload);write('examples/manifest-v2/qa-agent.signed.json',signed);write('examples/manifest-v2/verification-key.json',signer.verificationKey);
const correlation={organizationId:'org_example',employeeId:'employee_example',agentId:'agent_example_qa',threadId:'20000000-0000-4000-8000-000000000001',runId:'20000000-0000-4000-8000-000000000002'};
const task={objective:'Validate the checkout story and retain evidence.',workflow:'validate-story',workItem:{system:'jira',key:'QA-123'},inputs:{targetUrl:'https://qa.example.com'}};
write('examples/api/start-run.json',{agentId:payload.metadata.agentId,task});
write('examples/runtime/run-submit.json',{protocol:'agents-foundry/runtime/v1',type:'run.submit',commandId:'30000000-0000-4000-8000-000000000001',issuedAt:'2026-10-07T09:05:00Z',correlation,run:{runId:correlation.runId,threadId:correlation.threadId,task,runtimeProfile:payload.runtime.profile,manifest:signed,workspace:null}});
write('examples/runtime/run-started.json',{protocol:'agents-foundry/runtime/v1',eventId:'30000000-0000-4000-8000-000000000002',runId:correlation.runId,threadId:correlation.threadId,sequence:1,type:'run.started',occurredAt:'2026-10-07T09:05:01Z',correlation,payload:{runtimeSessionId:'30000000-0000-4000-8000-000000000003',kernel:'native-v1'}});
const parameters={issueKey:'QA-123'};
// The action envelope is structural; the gateway's tool-specific validation remains separate.
write('examples/runtime/action-request.json',{protocol:'agents-foundry/runtime/v1',requestId:'30000000-0000-4000-8000-000000000004',correlation:{...correlation,stepId:'30000000-0000-4000-8000-000000000005',toolCallId:'30000000-0000-4000-8000-000000000006'},action:'jira.read',toolId:'issue-tracker',toolVersion:'1.0.0',inputDigest:createHash('sha256').update(canonicalManifest(parameters)).digest('hex'),summary:'Read QA-123 in the configured Jira project.',parameters});
console.log('Generated source-resolved examples with an ephemeral demonstration signature; no private key saved.');
