import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

export default async function FeedPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) redirect("/login");

  return (
    <main className="auth-wrap">
      <section className="auth-card">
        <Link className="brand" href="/"><span className="brand-mark">✦</span>NOVA</Link>
        <h1>مرحباً بك في NOVA</h1>
        <p>تم تسجيل الدخول بنجاح باستخدام Supabase.</p>
        <p>{user.email}</p>
        <p>واجهة الخلاصة قيد البناء. سنضيف المنشورات والتفاعلات بعد تجهيز قاعدة البيانات وسياسات الخصوصية.</p>
        <form action="/auth/signout" method="post"><button className="button button-primary full-width" type="submit">تسجيل الخروج</button></form>
      </section>
    </main>
  );
}
