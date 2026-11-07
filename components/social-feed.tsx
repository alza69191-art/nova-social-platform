"use client";

import { useState, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

type FeedPost = {
  id: string;
  content: string;
  created_at: string;
  author: { display_name: string; username: string | null; avatar_url: string | null };
};

export default function SocialFeed({ initialPosts }: { initialPosts: FeedPost[] }) {
  const [content, setContent] = useState("");
  const [visibility, setVisibility] = useState("public");
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");
  const router = useRouter();

  async function publish(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const clean = content.trim();
    if (!clean) return;
    setBusy(true);
    setError("");
    try {
      const supabase = createClient();
      const { data: { user }, error: userError } = await supabase.auth.getUser();
      if (userError || !user) throw new Error("انتهت الجلسة. سجّل الدخول مجدداً.");
      const { error: insertError } = await supabase.from("posts").insert({ author_id: user.id, content: clean, visibility });
      if (insertError) throw insertError;
      setContent("");
      router.refresh();
    } catch (err) {
      setError(err instanceof Error ? err.message : "تعذر نشر المنشور.");
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="social-layout">
      <aside className="social-sidebar">
        <a className="brand" href="/"><span className="brand-mark">✦</span>NOVA</a>
        <nav className="social-nav" aria-label="التنقل الرئيسي">
          <a className="active" href="/feed">⌂ <span>الرئيسية</span></a>
          <a href="/explore">⌕ <span>استكشف</span></a>
          <a href="/videos">▷ <span>الفيديو</span></a>
          <a href="/messages">✉ <span>الرسائل</span></a>
          <a href="/communities">◎ <span>المجتمعات</span></a>
          <a href="/marketplace">◇ <span>السوق</span></a>
          <a href="/notifications">♧ <span>الإشعارات</span></a>
          <a href="/settings">⚙ <span>الإعدادات</span></a>
        </nav>
        <form action="/auth/signout" method="post"><button className="button button-ghost full-width" type="submit">تسجيل الخروج</button></form>
      </aside>
      <main className="feed-main">
        <header className="feed-header"><div><span className="eyebrow">مساحتك الاجتماعية</span><h1>الرئيسية</h1></div><a className="button button-primary" href="/profile">ملفي الشخصي</a></header>
        <section className="composer-card">
          <h2>شارك شيئاً جديداً</h2>
          <form onSubmit={publish}>
            <textarea value={content} onChange={(event) => setContent(event.target.value)} maxLength={5000} placeholder="بماذا تفكر اليوم؟" aria-label="محتوى المنشور" />
            <div className="composer-actions">
              <label>من يمكنه المشاهدة؟
                <select value={visibility} onChange={(event) => setVisibility(event.target.value)}>
                  <option value="public">الجميع</option><option value="followers">المتابعون</option><option value="private">أنا فقط</option>
                </select>
              </label>
              <button className="button button-primary" type="submit" disabled={busy || !content.trim()}>{busy ? "جارٍ النشر..." : "نشر المنشور"}</button>
            </div>
            {error && <p className="form-error" role="alert">{error}</p>}
          </form>
        </section>
        <div className="feed-section-title"><h2>أحدث المنشورات</h2><span>{initialPosts.length} منشور</span></div>
        {initialPosts.length === 0 ? (
          <section className="empty-feed"><div className="empty-icon">✦</div><h2>ابدأ موجز NOVA</h2><p>لا توجد منشورات ظاهرة حالياً. كن أول من يشارك فكرة أو تابع أشخاصاً لتظهر منشوراتهم هنا.</p></section>
        ) : initialPosts.map((post) => (
          <article className="feed-post" key={post.id}>
            <div className="feed-post-author"><div className="feed-avatar">{post.author.display_name.slice(0, 1) || "N"}</div><div><strong>{post.author.display_name || "عضو NOVA"}</strong><small>{post.author.username ? "@" + post.author.username + " · " : ""}{new Date(post.created_at).toLocaleString("ar", { dateStyle: "medium", timeStyle: "short" })}</small></div></div>
            <p className="feed-post-content">{post.content}</p>
            <div className="feed-post-footer"><span>منشور NOVA</span><span>التفاعلات والتعليقات قيد التفعيل</span></div>
          </article>
        ))}
      </main>
      <aside className="feed-rightbar">
        <section className="side-card"><h3>اكتشف NOVA</h3><p>تابع المجتمعات والقنوات والأشخاص الذين يشاركونك الاهتمامات.</p><a href="/explore">ابدأ الاستكشاف ←</a></section>
        <section className="side-card"><h3>قريباً على NOVA</h3><ul><li>القصص والفيديو</li><li>المحادثات والمجموعات</li><li>قنوات صناع المحتوى</li><li>السوق الرقمي</li></ul></section>
      </aside>
    </div>
  );
}
