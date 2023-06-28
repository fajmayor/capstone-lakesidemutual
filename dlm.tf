resource "aws_iam_role" "lakeside_dlm_lifecycle_role" {
  name = "lakeside-dlm-lifecycle-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "dlm.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lakeside_dlm_lifecycle" {
  name = "lakeside-dlm-lifecycle-policy"
  role = "${aws_iam_role.lakeside_dlm_lifecycle_role.id}"

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Action": [
            "ec2:CreateSnapshot",
            "ec2:DeleteSnapshot",
            "ec2:DescribeVolumes",
            "ec2:DescribeSnapshots"
         ],
         "Resource": "*"
      },
      {
         "Effect": "Allow",
         "Action": [
            "ec2:CreateTags"
         ],
         "Resource": "arn:aws:ec2:*::snapshot/*"
      }
   ]
}
EOF
}

resource "aws_dlm_lifecycle_policy" "lakeside" {
    description        = "DLM for Lakesidemutual-new"
    execution_role_arn = aws_iam_role.lakeside_dlm_lifecycle_role.arn
    tags               = {}
    tags_all           = {}

    policy_details {
        policy_type        = "EBS_SNAPSHOT_MANAGEMENT"

        resource_types     = [
            "INSTANCE",
        ]
        target_tags        = {
            "Name" = "lakesidemutual-ec2-new"
        }

        parameters {
            exclude_boot_volume = false
            no_reboot           = false
        }

        schedule {
            copy_tags     = true
            name          = "dlm Schedule 1"
            tags_to_add   = {}
            variable_tags = {
                "instance-id" = "$(instance-id)"
                "timestamp"   = "$(timestamp)"
            }

            create_rule {
                interval      = 12
                interval_unit = "HOURS"
                times         = [
                    "09:00",
                ]
            }

            cross_region_copy_rule {
                copy_tags = true
                encrypted = true
                target    = "us-west-2"

                retain_rule {
                    interval      = 15
                    interval_unit = "DAYS"
                }
            }

            retain_rule {
    
                interval = 15
                interval_unit = "DAYS"
            }
        }
    }
 

}
