resource "aws_sqs_queue" "strava_uploads" {
  name          = "whlsckr-strava-uploads"
  delay_seconds = 5
  fifo_queue    = false
}

