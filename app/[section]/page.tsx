import Link from "next/link";
import { notFound } from "next/navigation";

const sections: Record<string, { title: string; description: string; items: string[] }> = {
  explore: { title: "استكشف NOVA", description: "اكتشف الأشخاص والمنشورات والقنوات والمجتمعات التي تناسب اهتماماتك.", items: ["بحث شامل", "موضوعات ووسوم", "اقتراحات متابعة"] },
  videos: { title: "الفيديو وصناع المحتوى", description: "مساحة القنوات والفيديوهات والمقاطع القصيرة. تجهيز الرفع والتشغيل قيد التطوير.", items: ["قنوات المبدعين", "الفيديوهات", "قوائم التشغيل"] },
  messages: { title: "الرسائل", description: "المحادثات الفردية والجماعية ومشاركة الملفات. واجهة المراسلة ستُفعّل بعد استكمال تدفق المحادثات.", items: ["المحادثات", "الرسائل الجماعية", "المرفقات"] },
  communities: { title: "المجتمعات", description: "أنشئ مجموعات وشارك في مجتمعات عامة وخاصة.", items: ["المجموعات", "الصفحات", "الأحداث"] },
  marketplace: { title: "سوق NOVA", description: "اكتشف المنتجات والخدمات الرقمية. عمليات الدفع والشراء غير مفعّلة حالياً.", items: ["المنتجات", "الخدمات الرقمية", "ملفات البائعين"] },
  notifications: { title: "الإشعارات", description: "ستظهر هنا تحديثات المتابعة والتفاعلات والرسائل وطلبات الانضمام.", items: ["التفاعلات", "المتابعات", "تحديثات المجتمعات"] },
  settings: { title: "الإعدادات والخصوصية", description: "إدارة بيانات الحساب والخصوصية والجلسات وتفضيلات التنبيهات.", items: ["الحساب", "الخصوصية", "الأمان"] },
  profile: { title: "ملفي الشخصي", description: "ستتمكن من تعديل بياناتك وصورك ومنشوراتك وإدارة جمهور ملفك الشخصي.", items: ["المعلومات الشخصية", "المنشورات", "المتابعون"] },
};

export default async function ModulePage({ params }: { params: Promise<{ section: string }> }) {
  const { section } = await params;
  const module = sections[section];
  if (!module) notFound();

  return (
    <main className="module-shell">
      <header className="site-header"><Link className="brand" href="/"><span className="brand-mark">✦</span>NOVA</Link><Link className="button button-ghost" href="/feed">العودة إلى الرئيسية</Link></header>
      <section className="module-card">
        <span className="eyebrow">NOVA · مساحة جديدة</span>
        <h1>{module.title}</h1>
        <p>{module.description}</p>
        <div className="module-items">{module.items.map((item) => <div className="module-item" key={item}><span>✦</span>{item}</div>)}</div>
        <div className="module-status">هذه الوحدة ضمن خطة التطوير، ولم تُفعّل جميع وظائفها بعد.</div>
        <Link className="button button-primary" href="/feed">العودة إلى موجز NOVA</Link>
      </section>
    </main>
  );
}
