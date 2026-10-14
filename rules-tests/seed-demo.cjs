// Local disposable fixtures only. All services explicitly connect to emulators.
const {initializeApp, deleteApp} = require('firebase/app');
const {getAuth, connectAuthEmulator, createUserWithEmailAndPassword, signInWithEmailAndPassword, signOut} = require('firebase/auth');
const {getFirestore, connectFirestoreEmulator, doc, setDoc} = require('firebase/firestore');

async function main() {
  const app=initializeApp({apiKey:'demo-key', projectId:'demo-connect-smarter'});
  const auth=getAuth(app); connectAuthEmulator(auth,'http://127.0.0.1:9099',{disableWarnings:true});
  const db=getFirestore(app); connectFirestoreEmulator(db,'127.0.0.1',8080);
  const password='LocalDemo123!';
  async function account(email, profile) {
    let credential;
    try { credential=await createUserWithEmailAndPassword(auth,email,password); }
    catch(e) { if(e.code!=='auth/email-already-in-use') throw e; credential=await signInWithEmailAndPassword(auth,email,password); }
    await setDoc(doc(db,'users',credential.user.uid),profile,{merge:true});
    return credential.user.uid;
  }
  const owner=await account('company@example.test',{userType:'company',companyName:'Demo Studio',email:'company@example.test'});
  await setDoc(doc(db,'jobs','demo-flutter'),{ownerId:owner,title:'Flutter Developer',company:'Demo Studio',location:'Remote',isRemote:true,isFullTime:true,isPublic:true,skills:['flutter','dart','firebase'],description:'Build accessible Flutter interfaces and integrate tested APIs. This is a local demonstration listing.',education:'No degree required',minExperience:0,questions:['Describe how you manage application state.']});
  await signOut(auth);
  await account('candidate@example.test',{userType:'job_seeker',firstName:'Demo',lastName:'Candidate',email:'candidate@example.test',cvAnalysis:{profile:'Flutter Developer',skills:['flutter','dart','firebase'],matchReason:'Local demo fixture; not a real CV.',fileName:'demo-cv.txt',fileSizeBytes:100}});
  await deleteApp(app);
  console.log('Local demo accounts ready: company@example.test and candidate@example.test. Password: LocalDemo123!');
}
main().catch(error=>{console.error(error);process.exitCode=1;});
