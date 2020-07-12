# Zipping the source folder
data "archive_file" "compress_source" {
  # The format that will be used to compress the folder
  type = "zip"

  # The output path of the compressed folder
  output_path = "node_app/node-js-getting-started.zip"

  # The folder to be compressed
  source_dir = var.app_src_dir
}