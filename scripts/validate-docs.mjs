import fs from 'node:fs';
import path from 'node:path';
import {lint} from 'markdownlint/sync';
import {JSDOM} from 'jsdom';
import MarkdownIt from 'markdown-it';
const root=process.cwd();
const excluded=new Set(['.git','.sources','.validation','node_modules']);
const walk=dir=>fs.readdirSync(dir,{withFileTypes:true}).flatMap(e=>excluded.has(e.name)?[]:e.isDirectory()?walk(path.join(dir,e.name)):[path.join(dir,e.name)]);
const files=walk(root);const markdown=files.filter(f=>f.endsWith('.md'));
const inventory=JSON.parse(fs.readFileSync('source-inventory.json','utf8'));
const md=new MarkdownIt();
const issues=[];let links=0,sourceReferences=0,diagrams=0,jsonFiles=0;
const relative=f=>path.relative(root,f).replaceAll('\\','/');
const report=(file,message)=>issues.push({file:relative(file),message});
const parsed=new Map(markdown.map(f=>[f,md.parse(fs.readFileSync(f,'utf8'),{})]));
const anchors=new Map();
for(const [file,tokens] of parsed){const set=new Set();const counts=new Map();for(let i=0;i<tokens.length;i++){if(tokens[i].type!=='heading_open')continue;const title=tokens[i+1].content;const slug=title.toLowerCase().replace(/<[^>]+>/g,'').replace(/[^\p{L}\p{N}_\-\s]/gu,'').replace(/\s/g,'-');const n=counts.get(slug)||0;counts.set(slug,n+1);set.add(slug+(n?'-'+n:''));}anchors.set(file,set);}
// Structural Markdown rules. Line length, inline HTML, table alignment and fenced-language
// style are deliberately not enforced on verbatim historical/source declarations.
const config={default:false,MD001:true,MD003:{style:'atx'},MD009:true,MD010:true,MD012:true,MD018:true,MD019:true,MD022:true,MD023:true,MD024:{siblings_only:false},MD025:true,MD027:true,MD031:true,MD032:true,MD037:true,MD039:true,MD042:true,MD051:false};
const linted=lint({files:markdown,config});for(const [file,errors] of Object.entries(linted))for(const e of errors)report(file,`${e.ruleNames[0]} line ${e.lineNumber}: ${e.errorDetail??e.ruleDescription}`);
const dom=new JSDOM('<!doctype html><html><body></body></html>');globalThis.window=dom.window;globalThis.document=dom.window.document;
const {default:mermaid}=await import('mermaid');mermaid.initialize({startOnLoad:false,securityLevel:'strict'});
function checkLink(file,url){links++;if(url.startsWith('https://github.com/Agents-Foundry/employee-agent-platform/blob/')){const m=url.match(/\/blob\/([^/]+)\/([^?#]+)/);if(m?.[1]!==inventory.commit)report(file,`Unpinned platform reference ${url}`);else if(!Object.hasOwn(inventory.files,decodeURIComponent(m[2])))report(file,`Missing pinned source reference ${url}`);sourceReferences++;return;}if(/^[a-z][a-z0-9+.-]*:/i.test(url)||url.startsWith('//'))return;const [raw,fragment]=url.split('#');const target=raw?path.resolve(path.dirname(file),decodeURIComponent(raw.split('?')[0])):file;if(!target.startsWith(root+path.sep)&&target!==root){report(file,`Link outside documentation repository ${url}`);return;}if(!fs.existsSync(target)){report(file,`Broken internal link ${url}`);return;}if(fragment&&target.endsWith('.md')&&!anchors.get(target)?.has(decodeURIComponent(fragment)))report(file,`Missing anchor ${url}`);}
for(const [file,tokens] of parsed){
 const text=fs.readFileSync(file,'utf8');if(text.replace(/```[\s\S]*?```/g,'').includes('undefined'))report(file,'Contains undefined output outside source code; inspect generator');
 if(text.replace(/```[\s\S]*?```/g,'').trim().length<120)report(file,'Empty or insufficient document content');
 for(const token of tokens){if(token.type==='inline')for(const child of token.children||[]){if(child.type==='link_open')checkLink(file,child.attrGet('href'));if(child.type==='image')checkLink(file,child.attrGet('src'));}if(token.type==='fence'&&token.info==='mermaid'){diagrams++;try{await mermaid.parse(token.content);}catch(e){report(file,`Invalid Mermaid: ${e.message}`);}}
  if((token.type==='inline'||token.type==='heading_open')&&/^\s*(?:TODO|TBD|Coming soon|Under construction)\s*[:.!]?\s*$/i.test(token.content))report(file,'Unwritten placeholder content');
 }
}
for(const file of files.filter(f=>f.endsWith('.json'))){jsonFiles++;try{JSON.parse(fs.readFileSync(file,'utf8'));}catch(e){report(file,`Invalid JSON: ${e.message}`);}}
const routes=JSON.parse(fs.readFileSync('reference-data/routes.json','utf8'));for(const r of routes){const target=path.join(root,'docs/api',r.group+'.md');if(!fs.existsSync(target)||!fs.readFileSync(target,'utf8').includes(`## ${r.method} ${r.path}`))report(target,`Uncovered route ${r.method} ${r.path}`);}
// Ensure every guide is discoverable through another document; source declarations are not navigation.
for(const file of markdown.filter(f=>relative(f).startsWith('docs/'))){const needle=path.basename(file);if(!markdown.some(other=>other!==file&&fs.readFileSync(other,'utf8').includes(needle)))report(file,'No navigation reference found');}
const result={markdownFiles:markdown.length,links,sourceReferences,mermaidDiagrams:diagrams,jsonFiles,routes:routes.length,issues};fs.mkdirSync('.validation',{recursive:true});fs.writeFileSync('.validation/docs-report.json',JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify({...result,issues:issues.slice(0,100)},null,2));if(issues.length)process.exitCode=1;
