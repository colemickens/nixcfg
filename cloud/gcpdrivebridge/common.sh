export BUCKET_NAME="colemickens-images"

export img_path=$(echo gce/*.tar.gz)
img_name="$(basename "${img_path}")"
img_name="${img_name%".raw.tar.gz"}"
export img_name="${img_name//[._]/-}"
