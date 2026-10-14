const {readFileSync} = require('node:fs');
const {before, after, beforeEach, test} = require('node:test');
const {initializeTestEnvironment, assertSucceeds, assertFails} = require('@firebase/rules-unit-testing');
const {doc, setDoc, getDoc, updateDoc, collection, query, where, getDocs, deleteDoc} = require('firebase/firestore');
let env;
before(async () => {
  env = await initializeTestEnvironment({projectId:'demo-connect-smarter', firestore:{host:'127.0.0.1', port:8080, rules:readFileSync(require('node:path').join(__dirname, '../firestore.rules'),'utf8')}});
});
after(async () => { await env?.cleanup(); });
beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async ctx => {
    const db=ctx.firestore();
    await Promise.all([
      setDoc(doc(db,'users/alice'),{userType:'job_seeker'}),
      setDoc(doc(db,'users/bob'),{userType:'job_seeker'}),
      setDoc(doc(db,'users/company'),{userType:'company'}),
      setDoc(doc(db,'users/other-company'),{userType:'company'}),
      setDoc(doc(db,'jobs/job1'),{ownerId:'company',title:'Flutter developer',skills:['flutter'],isPublic:true}),
      setDoc(doc(db,'jobs/private'),{ownerId:'company',title:'Draft',skills:[],isPublic:false}),
      setDoc(doc(db,'interviews/result'),{candidateId:'alice',method:'practice-keyword-coverage-v1'}),
    ]);
  });
});
const db = uid => env.authenticatedContext(uid).firestore();
const application = {candidateId:'alice',employerId:'company',jobId:'job1',jobTitle:'Flutter developer',candidateName:'Alice',email:'alice@example.invalid',profile:'Flutter developer',skills:['flutter'],status:'submitted'};

test('anonymous access is denied',async()=>{
  await assertFails(getDoc(doc(env.unauthenticatedContext().firestore(),'jobs/job1')));
});
test('profiles and practice answers stay private',async()=>{
  await assertSucceeds(getDoc(doc(db('alice'),'users/alice')));
  await assertFails(getDoc(doc(db('company'),'users/alice')));
  await assertFails(getDoc(doc(db('bob'),'interviews/result')));
  await assertFails(getDoc(doc(db('company'),'interviews/result')));
});
test('roles cannot be escalated',async()=>{
  await assertFails(updateDoc(doc(db('alice'),'users/alice'),{userType:'company'}));
});
test('only the owner can complete an old profile with no valid role',async()=>{
  await env.withSecurityRulesDisabled(async ctx => {
    await setDoc(doc(ctx.firestore(),'users/incomplete'),{firstName:'Legacy'});
  });
  await assertFails(updateDoc(doc(db('alice'),'users/incomplete'),{userType:'company'}));
  await assertFails(updateDoc(doc(db('incomplete'),'users/incomplete'),{userType:'admin'}));
  await assertSucceeds(updateDoc(doc(db('incomplete'),'users/incomplete'),{userType:'company'}));
  await assertFails(updateDoc(doc(db('incomplete'),'users/incomplete'),{userType:'job_seeker'}));
});
test('new jobs reject malformed displayed fields and excessive lists',async()=>{
  const job = {ownerId:'company',title:'Developer',skills:['Dart'],isPublic:true};
  await assertSucceeds(setDoc(doc(db('company'),'jobs/valid'),job));
  for (const invalid of [
    {title:12}, {title:'x'.repeat(201)}, {company:[]}, {location:42},
    {description:{text:'not a string'}}, {education:false},
    {skills:'Dart'}, {skills:Array(101).fill('Dart')},
    {questions:Array(21).fill('Question')}, {minExperience:'3'},
    {minExperience:-1}, {isRemote:'yes'},
  ]) {
    await assertFails(setDoc(doc(db('company'),'jobs/invalid'),{...job,...invalid}));
  }
  await assertFails(updateDoc(doc(db('company'),'jobs/valid'),{isPublic:'true'}));
});
test('only job owner changes publication and deletes',async()=>{
  await assertFails(updateDoc(doc(db('other-company'),'jobs/job1'),{isPublic:false}));
  await assertSucceeds(updateDoc(doc(db('company'),'jobs/job1'),{isPublic:false}));
  await assertFails(updateDoc(doc(db('company'),'jobs/job1'),{ownerId:'other-company'}));
  await assertSucceeds(deleteDoc(doc(db('company'),'jobs/job1')));
});
test('public queries and owner queries work, drafts stay private',async()=>{
  await assertSucceeds(getDocs(query(collection(db('alice'),'jobs'),where('isPublic','==',true))));
  await assertSucceeds(getDocs(query(collection(db('company'),'jobs'),where('ownerId','==','company'))));
  await assertFails(getDoc(doc(db('alice'),'jobs/private')));
});
test('application creation validates candidate and employer',async()=>{
  await assertSucceeds(getDoc(doc(db('alice'),'applications/job1_alice')));
  await assertFails(setDoc(doc(db('bob'),'applications/job1_alice'),application));
  await assertFails(setDoc(doc(db('alice'),'applications/job1_alice'),{...application,employerId:'other-company'}));
  await assertSucceeds(setDoc(doc(db('alice'),'applications/job1_alice'),application));
  await assertFails(setDoc(doc(db('alice'),'applications/job1_alice'),application));
});
test('application status writable only by recipient employer',async()=>{
  await assertSucceeds(setDoc(doc(db('alice'),'applications/job1_alice'),application));
  await assertFails(updateDoc(doc(db('alice'),'applications/job1_alice'),{status:'shortlisted'}));
  await assertFails(updateDoc(doc(db('other-company'),'applications/job1_alice'),{status:'shortlisted'}));
  await assertSucceeds(updateDoc(doc(db('company'),'applications/job1_alice'),{status:'shortlisted'}));
  await assertFails(updateDoc(doc(db('company'),'applications/job1_alice'),{email:'changed@example.invalid'}));
  await assertSucceeds(getDocs(query(collection(db('company'),'applications'),where('employerId','==','company'))));
  await assertFails(getDocs(collection(db('other-company'),'applications')));
});
test('applications reject malformed displayed fields and excessive skills',async()=>{
  for (const invalid of [
    {jobTitle:[]}, {candidateName:42}, {candidateName:'x'.repeat(201)},
    {email:{address:'someone@example.invalid'}}, {email:'x'.repeat(321)},
    {profile:false}, {skills:'Dart'}, {skills:Array(101).fill('Dart')},
  ]) {
    await assertFails(setDoc(doc(db('alice'),'applications/job1_alice'),{...application,...invalid}));
  }
});
