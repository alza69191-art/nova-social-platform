import { redirect } from "next/navigation";
import SocialFeed from "@/components/social-feed";
import { createClient } from "@/lib/supabase/server";

export default async function FeedPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const { data: rows } = await supabase.from("posts").select("id, author_id, content, created_at").order("created_at", { ascending: false }).limit(30);
  const authorIds = [...new Set((rows ?? []).map((post) => post.author_id))];
  const { data: profiles } = authorIds.length
    ? await supabase.from("profiles").select("id, display_name, username, avatar_url").in("id", authorIds)
    : { data: [] };
  const profileById = new Map((profiles ?? []).map((profile) => [profile.id, profile]));
  const initialPosts = (rows ?? []).map((post) => ({
    id: post.id,
    content: post.content,
    created_at: post.created_at,
    author: {
      display_name: profileById.get(post.author_id)?.display_name ?? "عضو NOVA",
      username: profileById.get(post.author_id)?.username ?? null,
      avatar_url: profileById.get(post.author_id)?.avatar_url ?? null,
    },
  }));
  return <SocialFeed initialPosts={initialPosts} />;
}
