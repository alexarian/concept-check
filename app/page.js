"use client";

import { useCallback, useEffect, useLayoutEffect, useRef, useState } from "react";

const TOKEN_KEY = "cc-learner";
const OPEN_KEY = "cc-open-check";
const HINT = "Enter to send · Shift+Enter for a new line";
const FAILED = "That didn't go through. Your answer is safe. Try again.";
const STATUS = { in_progress: "IN PROGRESS", closed: "GAP CLOSED", not_yet: "NOT YET", no_gap: "NO GAP" };

function store(key, value) {
  try {
    if (value == null) localStorage.removeItem(key);
    else localStorage.setItem(key, String(value));
  } catch {}
}
function read(key) {
  try {
    return localStorage.getItem(key);
  } catch {
    return null;
  }
}

async function api(action, body = {}) {
  const res = await fetch(`/api/${action}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    const err = new Error(data.error || "failed");
    err.status = res.status;
    throw err;
  }
  return data;
}

const shortDate = (iso) => new Date(iso).toLocaleDateString("en-GB", { day: "numeric", month: "short" });

function Message({ m, canFlag, onFlag }) {
  if (m.from === "learner") {
    return (
      <div className="msg me">
        <div className="answer">{m.text}</div>
      </div>
    );
  }
  let body = null;
  if (m.kind === "explain") {
    body = (
      <>
        <p>{m.lead}</p>
        <p>
          <b>{m.question}</b>
        </p>
      </>
    );
  } else if (m.kind === "text") {
    body = <p>{m.text}</p>;
  } else if (m.kind === "case") {
    body = (
      <>
        <p className="tag mono">{m.label}</p>
        <p className="case">{m.question}</p>
        {m.flaggable && (
          <div className="acts">
            <button type="button" className="link" disabled={!canFlag} onClick={() => onFlag("unclear")}>
              This question is unclear
            </button>
            <button type="button" className="link" disabled={!canFlag} onClick={() => onFlag("not_taught")}>
              I wasn't taught this
            </button>
          </div>
        )}
      </>
    );
  } else if (m.kind === "followup") {
    body = (
      <>
        {m.said && (
          <>
            <p>You said:</p>
            <blockquote className="quote">“{m.said}”</blockquote>
          </>
        )}
        <p>One question:</p>
        <p className="case">{m.question}</p>
      </>
    );
  } else if (m.kind === "result") {
    body = (
      <>
        <span className={`badge mono ${m.ok ? "found" : "notyet"}`}>{m.ok ? "Gap closed" : "Not yet"}</span>
        <p>
          {m.ok
            ? "You missed the first case, then got a different one in your own words."
            : "The last case is still missing a point. Here's what was found."}
        </p>
        <p className="tag">Retries used: {m.used} of 3</p>
        <ul className="rows">
          {m.rows.map((r, i) => (
            <li key={i}>
              <span className={`tick ${r.found ? "y" : "n"}`}>{r.found ? "✓" : "✗"}</span>
              <span>
                {r.point}
                {r.found && r.quote && <span className="q">“{r.quote}”</span>}
              </span>
            </li>
          ))}
        </ul>
      </>
    );
  }
  return (
    <div className="msg bot">
      <div className="bubble">{body}</div>
    </div>
  );
}

export default function Home() {
  const [token, setToken] = useState(null);
  const [topics, setTopics] = useState([]);
  const [checks, setChecks] = useState([]);
  const [view, setView] = useState(null); // null = new check screen
  const [input, setInput] = useState("");
  const [working, setWorking] = useState(false);
  const [thinking, setThinking] = useState("");
  const [sent, setSent] = useState(null); // the answer shown while the server reads it
  const [error, setError] = useState(null); // { retry }
  const [consentTicked, setConsentTicked] = useState(false);
  const [consentError, setConsentError] = useState(false);
  const [drawer, setDrawer] = useState(false);
  const scrollRef = useRef(null);
  const inputRef = useRef(null);

  const refreshList = useCallback(async (t) => {
    if (!t) return;
    try {
      setChecks((await api("list", { token: t })).checks);
    } catch (e) {
      if (e.status === 401) {
        store(TOKEN_KEY, null);
        setToken(null);
      }
    }
  }, []);

  const runFollowup = useCallback(
    async (t, gapId) => {
      setWorking(true);
      setThinking("Finding your sentence…");
      setError(null);
      try {
        const { view: next } = await api("followup", { token: t, gapId });
        setView(next);
      } catch {
        setError({ retry: () => runFollowup(t, gapId) });
      } finally {
        setWorking(false);
        setThinking("");
      }
    },
    []
  );

  const show = useCallback(
    (t, next) => {
      setView(next);
      store(OPEN_KEY, next.gap.id);
      if (next.step === "needs_followup") runFollowup(t, next.gap.id);
    },
    [runFollowup]
  );

  const openCheck = useCallback(
    async (t, gapId) => {
      setError(null);
      setSent(null);
      setInput("");
      setWorking(true);
      try {
        const { view: next } = await api("open", { token: t, gapId });
        setWorking(false);
        show(t, next);
      } catch (e) {
        setWorking(false);
        if (e.status === 404) {
          store(OPEN_KEY, null);
          setView(null);
        } else {
          setError({ retry: () => openCheck(t, gapId) });
        }
      }
    },
    [show]
  );

  useEffect(() => {
    const t = read(TOKEN_KEY);
    const openId = read(OPEN_KEY);
    setToken(t);
    api("topics")
      .then((d) => setTopics(d.topics))
      .catch(() => setError({ retry: () => location.reload() }));
    if (t) {
      refreshList(t);
      if (openId) openCheck(t, Number(openId));
    }
  }, [refreshList, openCheck]);

  useLayoutEffect(() => {
    const el = scrollRef.current;
    if (el) el.scrollTop = el.scrollHeight;
  }, [view, sent, thinking]);

  useLayoutEffect(() => {
    const el = inputRef.current;
    if (!el) return;
    el.style.height = "auto";
    el.style.height = Math.min(el.scrollHeight, 200) + "px";
  }, [input]);

  useEffect(() => {
    const onKey = (e) => e.key === "Escape" && setDrawer(false);
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, []);

  async function pickTopic(topicId) {
    if (working) return;
    let t = token;
    if (!t && !consentTicked) {
      setConsentError(true);
      return;
    }
    setConsentError(false);
    setError(null);
    setWorking(true);
    try {
      if (!t) {
        t = (await api("consent")).token;
        store(TOKEN_KEY, t);
        setToken(t);
      }
      const { view: next } = await api("start", { token: t, topicId });
      show(t, next);
      refreshList(t);
      setTimeout(() => inputRef.current?.focus(), 0);
    } catch {
      setError({ retry: () => pickTopic(topicId) });
    } finally {
      setWorking(false);
    }
  }

  async function submit(text) {
    if (!view || working || !text.trim()) return;
    const gapId = view.gap.id;
    const caseId = view.pending?.caseId;
    setInput("");
    setSent(text);
    setError(null);
    setWorking(true);
    setThinking("Reading your answer…");
    try {
      const { view: next } = await api("answer", { token, gapId, caseId, text });
      setSent(null);
      setWorking(false);
      setThinking("");
      show(token, next);
      refreshList(token);
      setTimeout(() => inputRef.current?.focus(), 0);
    } catch (e) {
      setSent(null);
      setWorking(false);
      setThinking("");
      setInput(text);
      if (e.status === 409) openCheck(token, gapId);
      else setError({ retry: null }); // Try again resends what's in the box
    }
  }

  async function flag(reason) {
    if (!view?.pending || working) return;
    setError(null);
    setWorking(true);
    try {
      const { view: next } = await api("flag", { token, gapId: view.gap.id, caseId: view.pending.caseId, reason });
      show(token, next);
    } catch {
      setError({ retry: () => flag(reason) });
    } finally {
      setWorking(false);
    }
  }

  function newCheck() {
    if (working) return;
    store(OPEN_KEY, null);
    setView(null);
    setInput("");
    setSent(null);
    setError(null);
    setDrawer(false);
  }

  const step = view?.step;
  const done = step === "done";
  const boxDisabled = !view || working || done || step === "needs_followup";
  const placeholder = !view
    ? "Pick a topic above to start"
    : step === "reply"
      ? "Your thinking (or type “skip”)"
      : "Type your answer…";
  const lastIndex = view ? view.messages.length - 1 : -1;

  return (
    <div className={`app${drawer ? " open" : ""}`}>
      <aside className="side" aria-label="Your checks">
        <div className="side-top">
          <p className="wordmark">Concept Check</p>
          <button className="new" type="button" onClick={newCheck} disabled={working}>
            <span aria-hidden="true">+</span> New check
          </button>
        </div>
        <p className="side-label mono">Previous checks</p>
        <ul className="chats">
          {checks.map((c) => (
            <li key={c.id}>
              <button
                type="button"
                aria-current={view?.gap.id === c.id}
                disabled={working}
                onClick={() => {
                  setDrawer(false);
                  openCheck(token, c.id);
                }}
              >
                <span className="t">{c.topic}</span>
                <span className="m">
                  {shortDate(c.created_at)} ·{" "}
                  {c.status === "closed" ? <span className="ok">{STATUS.closed}</span> : STATUS[c.status]}
                </span>
              </button>
            </li>
          ))}
        </ul>
        <div className="side-foot">Saved on this device, without your name.</div>
      </aside>
      <div className="scrim" onClick={() => setDrawer(false)} />

      <main className="main">
        <div className="topbar">
          <button className="menu" type="button" aria-label="Open previous checks" onClick={() => setDrawer(true)}>
            ☰
          </button>
          <span className="wordmark">Concept Check</span>
        </div>

        <div className="scroll" ref={scrollRef}>
          <div className="thread">
            {!view ? (
              <div className="welcome">
                <h1>Which Module 2 idea do you want to check?</h1>
                <p>
                  Explain it in your own words. We'll find where it turns into a stock phrase, ask you one question, and
                  give you a new case to try.
                </p>
                <div className="chips">
                  {topics.map((t, i) => (
                    <button key={t.id} type="button" className="chip" disabled={working} onClick={() => pickTopic(t.id)}>
                      {i + 1}. {t.title}
                    </button>
                  ))}
                </div>
              </div>
            ) : (
              view.messages.map((m, i) => (
                <Message
                  key={i}
                  m={m}
                  canFlag={!done && !working && !sent && i === lastIndex && m.flagsOpen}
                  onFlag={flag}
                />
              ))
            )}
            {sent != null && (
              <div className="msg me">
                <div className="answer">{sent}</div>
              </div>
            )}
            {thinking && <p className="typing">{thinking}</p>}
          </div>
        </div>

        <div className="composer-wrap">
          {done ? (
            <div className="ended">This check is finished. Start a new check from the sidebar.</div>
          ) : (
            <form
              className="composer"
              onSubmit={(e) => {
                e.preventDefault();
                submit(input);
              }}
            >
              <div className="box">
                <textarea
                  ref={inputRef}
                  rows={1}
                  value={input}
                  placeholder={placeholder}
                  aria-label="Your answer"
                  disabled={boxDisabled}
                  onChange={(e) => setInput(e.target.value)}
                  onKeyDown={(e) => {
                    if (e.key === "Enter" && !e.shiftKey && !e.nativeEvent.isComposing) {
                      e.preventDefault();
                      submit(input);
                    }
                  }}
                />
                <button className="send" type="submit" aria-label="Send" disabled={boxDisabled || !input.trim()}>
                  ↑
                </button>
              </div>
              <div className="under">
                {error ? (
                  <span className="err">
                    {FAILED}
                    <button type="button" className="retry" onClick={() => (error.retry ? error.retry() : submit(input))}>
                      Try again
                    </button>
                  </span>
                ) : consentError && !view ? (
                  <span className="err">Tick the box below first, so your answers can be saved.</span>
                ) : (
                  <span>{HINT}</span>
                )}
                {!view && !token && (
                  <label className="consent">
                    <input
                      type="checkbox"
                      checked={consentTicked}
                      onChange={(e) => {
                        setConsentTicked(e.target.checked);
                        if (e.target.checked) setConsentError(false);
                      }}
                    />
                    I agree my answers are saved, without my name.
                  </label>
                )}
              </div>
            </form>
          )}
        </div>
      </main>
    </div>
  );
}
