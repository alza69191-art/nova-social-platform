import Link from "next/link";

const features = [
  { icon: "✦", title: "مساحة اجتماعية واحدة", text: "شارك أفكارك وصورك وقصصك، وتفاعل مع محتوى الأشخاص والمجتمعات التي تهمك." },
  { icon: "▶", title: "الفيديو وصنّاع المحتوى", text: "اكتشف القنوات، تابع المبدعين، واجمع محتواك المرئي في تجربة واحدة." },
  { icon: "◎", title: "المجتمعات والمحادثات", text: "أنشئ مجموعاتك، انضم إلى مجتمعاتك، وتواصل برسائل مباشرة." },
  { icon: "◇", title: "السوق الرقمي", text: "اعرض المنتجات والخدمات الرقمية واكتشف عروض البائعين." },
  { icon: "⌁", title: "تحكم وخصوصية", text: "إعدادات واضحة للجمهور والحظر والإبلاغ وإدارة الحساب." },
  { icon: "✧", title: "تجربة عربية أولاً", text: "واجهة عربية باتجاه RTL، مع تصميم متجاوب للهاتف والحاسوب." },
];

export default function HomePage() {
  return (
    <>
      <header className="site-header">
        <Link className="brand" href="/"><span className="brand-mark">✦</span>NOVA</Link>
        <nav className="nav-actions">
          <Link className="button button-ghost" href="/login">تسجيل الدخول</Link>
          <Link className="button button-primary" href="/signup">إنشاء حساب</Link>
        </nav>
      </header>
      <main>
        <section className="hero">
          <div>
            <span className="eyebrow">✦ عالمك الرقمي في مكان واحد</span>
            <h1>تواصل، اكتشف، وشارك <span>بطريقتك.</span></h1>
            <p className="hero-copy">NOVA مساحة تجمع المنشورات والفيديو والمجتمعات والمحادثات والأسواق الرقمية، ضمن تجربة اجتماعية عربية متكاملة.</p>
            <div className="hero-actions">
              <Link className="button button-primary" href="/signup">ابدأ رحلتك مجاناً</Link>
              <Link className="button button-ghost" href="#features">اكتشف NOVA</Link>
            </div>
          </div>
          <div className="preview" aria-label="معاينة توضيحية للواجهة">
            <div className="preview-top"><span className="preview-title">مساحتك في NOVA</span><span className="preview-pill">معاينة تجريبية</span></div>
            <div className="story-row">
              {["قصتك", "ليان", "أحمد", "سارة", "عمر"].map((name, i) => <div className="story" key={name}><div className="story-avatar" style={{ opacity: 1 - i * .08 }} />{name}</div>)}
            </div>
            <article className="post">
              <div className="post-head"><div className="avatar" /><div><div className="post-name">مجتمع المبدعين</div><div className="post-time">منذ لحظات · عام</div></div></div>
              <p className="post-text">كل فكرة عظيمة تبدأ بخطوة صغيرة. شارك إبداعك اليوم واكتشف أشخاصاً يشاركونك الاهتمامات.</p>
              <div className="post-media" />
            </article>
          </div>
        </section>
        <section className="features" id="features">
          <div className="section-heading"><h2>كل ما يقرّبك مما تحب</h2><p>منصة واحدة، ومساحات متعددة للتعبير والتواصل والاكتشاف.</p></div>
          <div className="feature-grid">
            {features.map((feature) => <article className="feature-card" key={feature.title}><div className="feature-icon">{feature.icon}</div><h3>{feature.title}</h3><p>{feature.text}</p></article>)}
          </div>
        </section>
      </main>
      <footer className="site-footer">NOVA © {new Date().getFullYear()} — نبني مساحة رقمية أكثر اتصالاً.</footer>
    </>
  );
}
