# Supabase Storage Setup - Service Project Images (Public Access)

**Role**: CEO only (requires Supabase dashboard access)
**Duration**: 5 minutes
**Frequency**: One-time setup

---

## Context
Service Projects feature requires image storage. Since the app doesn't have authentication (designed for small club use), we configure public upload/read/delete access.

---

## Setup Steps

### 1. Access Supabase Dashboard
- Navigate to: https://supabase.com/dashboard
- Sign in to Georgetown Rotary project
- Click **Storage** in left sidebar

### 2. Create Storage Bucket
- Click **"New bucket"** button
- **Bucket name**: `project-images`
- **Public bucket**: ✅ **Enable** (allows public URL access)
- Click **"Create bucket"**

### 3. Configure Public Policies
Navigate to **Storage > Policies** and create these policies:

```sql
-- Allow anyone to upload project images
CREATE POLICY "Anyone can upload project images"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'project-images');

-- Allow public read access
CREATE POLICY "Project images are publicly accessible"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'project-images');

-- Allow anyone to update project images
CREATE POLICY "Anyone can update project images"
ON storage.objects FOR UPDATE
TO public
USING (bucket_id = 'project-images');

-- Allow anyone to delete project images
CREATE POLICY "Anyone can delete project images"
ON storage.objects FOR DELETE
TO public
USING (bucket_id = 'project-images');
```

---

## Verification

### Test Upload
1. Open app in browser
2. Navigate to Service Projects → New Project
3. Click "Upload Image" and select an image
4. Should see: "Compressed: [size] → [smaller size]" in console
5. Image should upload successfully and display in preview

### Check Supabase Dashboard
1. Go to Storage → project-images bucket
2. Confirm uploaded image appears
3. Click image to view public URL

---

## Troubleshooting

**"Failed to upload image" error:**
- ✅ Confirm `project-images` bucket exists in Storage
- ✅ Verify bucket is marked as **Public**
- ✅ Check all 4 policies exist (INSERT, SELECT, UPDATE, DELETE)
- ✅ Verify policies target **public** role, not **authenticated**
- ✅ Check browser console for specific Supabase error

**Images upload but don't display:**
- ✅ Verify SELECT policy exists for public role
- ✅ Test image URL directly in browser
- ✅ Check for CORS errors in console

---

## Security Note
This configuration allows anyone with the app URL to upload/delete images. This is acceptable for:
- Small club use (~50 members)
- Internal tool (not public-facing)
- Rotary members trust environment

For production with external access, add authentication layer.
