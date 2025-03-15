// --------------------------------------------------------
// THANOS
// --------------------------------------------------------

resource "minio_iam_user" "homeassistant_thanos_stone" {
  name          = "homeassistant-thanos-store"
  force_destroy = true
  update_secret = true
}

resource "minio_s3_bucket" "homeassistant_thanos_stone" {
  bucket        = "homeassistant-thanos-store"
  force_destroy = true
  acl           = "private"
}

resource "minio_iam_service_account" "homeassistant_thanos_stone" {
  target_user = minio_iam_user.homeassistant_thanos_stone.name
}

resource "minio_iam_policy" "homeassistant_thanos_stone" {
  name   = "homeassistant-thanos-store"
  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement": [
    {
      "Sid":"HomeAssistantThanosStoreAdmin",
      "Effect": "Allow",
      "Action": ["s3:*"],
      "Principal":"*",
      "Resource": ["${minio_s3_bucket.homeassistant_thanos_stone.arn}", "${minio_s3_bucket.homeassistant_thanos_stone.arn}/*"]
    }
  ]
}
EOF
}

resource "minio_iam_user_policy_attachment" "homeassistant_thanos_stone" {
  user_name   = minio_iam_user.homeassistant_thanos_stone.id
  policy_name = minio_iam_policy.homeassistant_thanos_stone.name
}

resource "null_resource" "minio" {
  depends_on = [
    // homeassistant-thanos-store
    minio_iam_user.homeassistant_thanos_stone,
    minio_iam_service_account.homeassistant_thanos_stone,
    minio_iam_user_policy_attachment.homeassistant_thanos_stone,
    minio_iam_policy.homeassistant_thanos_stone,
    minio_s3_bucket.homeassistant_thanos_stone,
  ]
}