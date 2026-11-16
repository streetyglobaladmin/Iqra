const state = { role: null, profiles: [], activeProfile: null, lessons: [] };
const $ = id => document.getElementById(id);
const message = (msg, type='') => { $('message').textContent = msg; $('message').className = `notice ${type}`; };
const csrf = () => decodeURIComponent(document.cookie.split('; ').find(x => x.startsWith('iqra_csrf='))?.split('=')[1] || '');
async function request(path, options={}) {
  const method = options.method || 'GET';
  const headers = { 'Accept':'application/json', ...(options.body ? {'Content-Type':'application/json'} : {}), ...(method !== 'GET' ? {'X-IQRA-CSRF':csrf()} : {}) };
  const res = await fetch(path, { credentials:'same-origin', headers, ...options });
  let payload = {}; try { payload = await res.json(); } catch {}
  if (!res.ok) throw new Error(typeof payload.detail === 'string' ? payload.detail : `Request failed (${res.status})`);
  return payload;
}
function element(name, className='', content='') { const el=document.createElement(name); if(className)el.className=className; if(content)el.textContent=content;return el; }
async function initialize() {
  const session = await request('/api/v1/session'); state.role = session.role;
  $('session-label').textContent = session.email || 'Guest';
  $('signout').hidden = !session.signed_in;
  $('auth-panel').hidden = session.signed_in;
  $('learning-panel').hidden = !session.signed_in;
  $('staff-panel').hidden = !['admin','reviewer'].includes(session.role);
  if (session.signed_in) { message(`Signed in as ${session.email}`,'success'); await loadProfiles(); if(['admin','reviewer'].includes(session.role)) await loadStaff(); }
  else { message('Sign in or create a free account to begin your learning journey.'); }
}
async function loadProfiles(preferredId=null) {
  state.profiles = await request('/api/v1/profiles');
  const sel=$('profile-select'); sel.replaceChildren();
  for(const p of state.profiles){const opt=element('option','',`${p.name} · ${p.kind==='kids'?'Kids':'Adult'}`);opt.value=p.id;sel.append(opt);}
  $('parent-panel').hidden = state.role !== 'parent';
  if(preferredId)sel.value=String(preferredId);
  state.activeProfile = Number(sel.value)||null;
  $('welcome').textContent = state.profiles.find(p=>p.id===state.activeProfile)?.name || 'Your journey';
  await loadLessons();
}
async function loadLessons() {
  const root=$('lesson-list');root.replaceChildren();
  if(!state.activeProfile){root.append(element('p','empty','Create or select a learning profile to begin.'));return;}
  const result=await request(`/api/v1/learning/lessons?profile_id=${encodeURIComponent(state.activeProfile)}`);
  state.lessons=result.lessons;
  if(!state.lessons.length){root.append(element('p','empty','This learning pathway is being reviewed. Lessons will appear here after educational review and publication.'));return;}
  const passed=state.lessons.filter(l=>l.completed).length;
  root.append(element('p','lesson-meta',`${passed} of ${state.lessons.length} lessons complete`));
  for(const lesson of state.lessons){
    const card=element('article',`lesson ${lesson.completed?'completed':''} ${!lesson.unlocked?'locked':''}`);
    card.append(element('p','lesson-meta',`LESSON ${lesson.slug} · ${lesson.source_ref}`));
    card.append(element('h4','',`${lesson.completed?'✓ ':''}${lesson.title}`));
    card.append(element('p','',lesson.description));
    if(!lesson.unlocked){card.append(element('p','lesson-meta','Complete your previous lesson to unlock this one.'));}
    else if(lesson.completed){card.append(element('p','lesson-meta','Completed · Continue when you are ready.'));}
    else {
      card.append(element('p','',lesson.prompt));
      const choices=element('div','answers');
      lesson.options.forEach((option,index)=>{const b=element('button','',option);b.type='button';b.addEventListener('click',async()=>{
        [...choices.children].forEach(el=>el.disabled=true);
        const eventId=crypto.randomUUID();
        try { const r=await request('/api/v1/learning/answer',{method:'POST',body:JSON.stringify({profile_id:state.activeProfile,lesson_id:lesson.id,selected_index:index,event_id:eventId})});
          message(r.correct?'Correct. Your progress has been saved.':'Not quite. Try the lesson again when ready.',r.correct?'success':'');await loadLessons();
        }catch(e){message(e.message,'error');[...choices.children].forEach(el=>el.disabled=false);}
      });choices.append(b);});card.append(choices);
    }
    root.append(card);
  }
}
async function loadStaff(){
  const lessons=await request('/api/v1/admin/lessons');const root=$('staff-lessons');root.replaceChildren();
  $('staff-title').textContent=state.role==='reviewer'?'Review curriculum':'Manage curriculum';
  for(const lesson of lessons){const row=element('div','staff-row');row.append(element('strong','',lesson.title));row.append(element('p','',`${lesson.track.toUpperCase()} · ${lesson.state.toUpperCase()} · v${lesson.version} · ${lesson.source_ref}`));
    const actions=element('div','staff-actions');const canReview=state.role==='reviewer'&&lesson.state==='draft';const canPublish=state.role==='admin'&&lesson.state==='reviewed';
    if(canReview||canPublish){const btn=element('button','button secondary',canReview?'Confirm qualified review':'Publish reviewed lesson');btn.type='button';btn.addEventListener('click',async()=>{btn.disabled=true;try{await request(`/api/v1/admin/lessons/${lesson.id}/${canReview?'review':'publish'}`,{method:'POST'});message(`Lesson ${canReview?'reviewed':'published'}.`,'success');await loadStaff();await loadLessons();}catch(e){message(e.message,'error');btn.disabled=false;}});actions.append(btn);}
    row.append(actions);root.append(row);}
}
async function formSubmit(event,path,fields){event.preventDefault();const btn=event.currentTarget.querySelector('button[type=submit]');btn.disabled=true;try{await request(path,{method:'POST',body:JSON.stringify(fields)});await initialize();}catch(e){message(e.message,'error');}finally{btn.disabled=false;}}
$('login-form').addEventListener('submit',e=>{const data=Object.fromEntries(new FormData(e.currentTarget));formSubmit(e,'/api/v1/auth/login',data);});
$('register-form').addEventListener('submit',e=>{const data=Object.fromEntries(new FormData(e.currentTarget));data.adult_confirmed=data.adult_confirmed==='true';formSubmit(e,'/api/v1/auth/register',data);});
$('child-form').addEventListener('submit',async e=>{e.preventDefault();const data=Object.fromEntries(new FormData(e.currentTarget));try{const child=await request('/api/v1/profiles/child',{method:'POST',body:JSON.stringify(data)});e.currentTarget.reset();message('Child profile created. Your child does not need a separate login.','success');await loadProfiles(child.id);}catch(err){message(err.message,'error');}});
$('profile-select').addEventListener('change',async e=>{state.activeProfile=Number(e.target.value);await loadLessons();});
$('signout').addEventListener('click',async()=>{try{await request('/api/v1/auth/logout',{method:'POST'});state.role=null;await initialize();}catch(e){message(e.message,'error');}});
initialize().catch(e=>message(`Website connection unavailable: ${e.message}`,'error'));