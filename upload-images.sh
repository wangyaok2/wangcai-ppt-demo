#!/bin/bash

# 配置
TOKEN=$(curl -s -X POST "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal" \
  -H "Content-Type: application/json" \
  -d '{"app_id":"cli_a9245f299a38dccb","app_secret":"gLKE1BGXMHjDT1ERl85HXfkKqcw7MtDf"}' | jq -r '.tenant_access_token')

# V5文件夹token
V5_FOLDER="Tw7pf3scAloDoIdhp48cH4Pmnvd"

echo "开始上传29张图片..."

# 上传所有图片
for i in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29; do
  file="images/page-${i}.png"
  
  if [ -f "$file" ]; then
    echo "上传第${i}页..."
    
    # 上传到飞书
    response=$(curl -s -X POST "https://open.feishu.cn/open-apis/drive/v1/files/upload_all" \
      -H "Authorization: Bearer $TOKEN" \
      -F "file=@$file" \
      -F "parent_node_token=$V5_FOLDER" \
      -F "block_size=0" \
      -F "file_name=page-${i}.png" \
      -F "file_type=png")
    
    if echo "$response" | jq -e '.code == 0'; then
      file_token=$(echo "$response" | jq -r '.data.file_token')
      echo "✅ 成功: file_token: $file_token"
      
      # 获取临时下载链接
      download_url=$(curl -s -X GET "https://open.feishu.cn/open-apis/drive/v1/files/${file_token}/download" \
        -H "Authorization: Bearer $TOKEN" | jq -r '.data.tmp_download_url')
      
      echo "   下载链接: $download_url"
    else
      echo "❌ 失败: $(echo "$response" | jq -r '.')"
    fi
    
    sleep 2
  else
    echo "跳过第${i}页（文件不存在）"
  fi
done

echo "上传完成！"