// Cloudflare Worker: receive quiz JSON and commit into GitHub repo as a file
// Set environment variables in Cloudflare:
//  GITHUB_TOKEN : fine-grained PAT with 'contents:write' to the repo
//  REPO_OWNER   : e.g., 'Nataliogc'
//  REPO_NAME    : e.g., 'formacion-manipulacion'
//  BRANCH       : e.g., 'main'
//  BASE_PATH    : e.g., 'data/submissions'
export default {
  async fetch(request, env, ctx) {
    if (request.method !== 'POST') {
      return new Response(JSON.stringify({error:'method not allowed'}), {status:405});
    }
    const ip = request.headers.get('CF-Connecting-IP') || '';
    let body;
    try {
      body = await request.json();
    } catch {
      return new Response(JSON.stringify({error:'invalid json'}), {status:400});
    }
    // Minimal validation
    if (!body || typeof body !== 'object' || !body.name || !body.blockId) {
      return new Response(JSON.stringify({error:'missing fields'}), {status:400});
    }
    const now = new Date();
    const ymd = now.toISOString().slice(0,10).replace(/-/g,'');
    const id = crypto.randomUUID();
    const path = `${env.BASE_PATH || 'data/submissions'}/${ymd}/${id}.json`;

    // Build commit to GitHub
    const content = btoa(unescape(encodeURIComponent(JSON.stringify({
      ...body,
      _ip: ip,
      _ts: now.toISOString()
    }, null, 2))));

    const ghUrl = `https://api.github.com/repos/${env.REPO_OWNER}/${env.REPO_NAME}/contents/${path}`;
    const commit = {
      message: `quiz: add submission ${id}`,
      content: content,
      branch: env.BRANCH || 'main',
      committer: { name: "Quiz Bot", email: "quizbot@example.com" }
    };

    const resp = await fetch(ghUrl, {
      method: 'PUT',
      headers: {
        'Authorization': `Bearer ${env.GITHUB_TOKEN}`,
        'Accept': 'application/vnd.github+json',
        'User-Agent': 'quiz-worker/1.0'
      },
      body: JSON.stringify(commit)
    });

    if (!resp.ok) {
      const txt = await resp.text();
      return new Response(JSON.stringify({error:'github error', details:txt}), {status:502});
    }
    const data = await resp.json();
    return new Response(JSON.stringify({ok:true, path:data.content?.path || path}), {
      headers: {'Content-Type':'application/json'}
    });
  }
}
