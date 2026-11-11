resource "aws_ecr_repository" "app" {
  name = "${var.project}-api"

  # Once a tag is pushed, nobody can overwrite it. Every deploy = exactly one build.
  image_tag_mutability = "IMMUTABLE"

  # Scan every new image for known CVEs (vulnerabilities) on push.
  image_scanning_configuration {
    scan_on_push = true
  }

  # Lets `terraform destroy` delete the repo even if it still has images (lab convenience).
  force_delete = true
}

# Keep the registry tidy: only the 10 newest images survive.
resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = { type = "expire" }
    }]
  })
}
