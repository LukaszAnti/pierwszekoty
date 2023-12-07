provider "aws" {
  region     = "eu-central-1"
  access_key = "AKIARV4NRUREVQDZ5GHE"
  secret_key = "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"
}

resource "aws_s3_bucket" "static_website" {
  bucket = "moje-wiaderko-420"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

