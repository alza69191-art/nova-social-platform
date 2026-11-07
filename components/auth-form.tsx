"use client";

import Link from "next/link";
import { useState, type FormEvent } from "react";
import { createClient } from "@/lib/supabase/client";

type AuthFormProps = { mode: "login" | "signup" };

export default function AuthForm({ mode }: AuthFormProps) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError("");
    setMessage("");
    setLoading(true);

    try {
      const supabase = createClient();
      if (mode === "signup") {
        const { data, error: authError } = await supabase.auth.signUp({
          email,
          password,
          options: { emailRedirectTo: `${window.location.origin}/auth/callback` },
        });
        if (authError) throw authError;
        setMessage(data.session ? "تم إنشاء الحساب بنجاح." : "تحقق من بريدك الإلكتروني لتأكيد الحساب.");
      } else {
        const { error: authError } = await supabase.auth.signInWithPassword({ email, password });
        if (authError) throw authError;
        window.location.assign("/feed");
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : "حدث خطأ غير متوقع.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <main className="auth-wrap">
      <section className="auth-card">
        <Link className="brand" href="/"><span className="brand-mark">✦</span>NOVA</Link>
        <h1>{mode === "signup" ? "أنشئ حسابك" : "مرحباً بعودتك"}</h1>
        <p>{mode === "signup" ? "انضم إلى NOVA وابدأ اكتشاف مساحتك الرقمية." : "سجّل الدخول للعودة إلى مساحتك في NOVA."}</p>
        <form onSubmit={handleSubmit}>
          <label className="form-field">البريد الإلكتروني<input type="email" autoComplete="email" required value={email} onChange={(e) => setEmail(e.target.value)} placeholder="name@example.com" /></label>
          <label className="form-field">كلمة المرور<input type="password" autoComplete={mode === "signup" ? "new-password" : "current-password"} minLength={8} required value={password} onChange={(e) => setPassword(e.target.value)} placeholder="8 أحرف على الأقل" /></label>
          {error && <p className="form-error" role="alert">{error}</p>}
          {message && <p className="form-success" role="status">{message}</p>}
          <button className="button button-primary full-width" type="submit" disabled={loading}>{loading ? "جارٍ التنفيذ..." : mode === "signup" ? "إنشاء الحساب" : "تسجيل الدخول"}</button>
        </form>
        <p>{mode === "signup" ? "لديك حساب بالفعل؟ " : "ليس لديك حساب؟ "}<Link href={mode === "signup" ? "/login" : "/signup"} style={{ color: "var(--orange-dark)", fontWeight: 800 }}>{mode === "signup" ? "تسجيل الدخول" : "إنشاء حساب"}</Link></p>
      </section>
    </main>
  );
}
