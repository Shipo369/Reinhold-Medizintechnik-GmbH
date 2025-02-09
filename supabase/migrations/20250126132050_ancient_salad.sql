-- Create function to get exam attempts with details
CREATE OR REPLACE FUNCTION get_exam_attempts_with_details()
RETURNS TABLE (
  id UUID,
  user_id UUID,
  exam_id UUID,
  score INTEGER,
  passed BOOLEAN,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ,
  email TEXT,
  full_name TEXT,
  exam_title TEXT,
  passing_score INTEGER,
  max_attempts INTEGER
) 
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Check if user is admin
  IF NOT EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid()
    AND role = 'admin'
  ) THEN
    RETURN;
  END IF;

  RETURN QUERY
  SELECT 
    a.id,
    a.user_id,
    a.exam_id,
    a.score,
    a.passed,
    a.started_at,
    a.completed_at,
    a.created_at,
    p.email,
    p.full_name,
    e.title as exam_title,
    e.passing_score,
    e.max_attempts
  FROM exam_attempts a
  JOIN auth.users u ON a.user_id = u.id
  JOIN profiles p ON u.id = p.id
  JOIN module_exams e ON a.exam_id = e.id
  ORDER BY a.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- Grant execute permission on the function
GRANT EXECUTE ON FUNCTION get_exam_attempts_with_details() TO authenticated;