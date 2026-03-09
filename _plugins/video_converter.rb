# Jekyll插件：Chirpy主题优化版MP4转视频标签插件
# 文件名：_plugins/video_converter.rb

module Jekyll
  # 使用Generator而不是Converter
  class VideoConverter < Generator
    safe true
    priority :high

    def generate(site)
      # 遍历所有页面和文章
      all_docs = site.pages + site.posts.docs + site.documents
      all_docs.each do |doc|
        next unless doc.content.respond_to?(:gsub)
        
        # 检查文档是否包含MP4相关内容
        if doc.content.match(/\.mp4/i)
          original_content = doc.content
          
          # 处理HTML中a标签包裹img标签的情况
          doc.content = doc.content.gsub(/(<a\s+[^>]*href=["']([^"']*\.mp4)["'][^>]*>\s*<img\s+[^>]*src=["']([^"']*\.mp4)["'][^>]*>\s*<\/a>)/mi) do |match|
            full_match = $1
            href_url = $2
            
            # 确保路径以/开头
            formatted_url = ensure_leading_slash(href_url)
            
            # 检查是否是本地文件
            if is_local_file?(href_url)
              %Q|<video controls width="100%"> <source src="#{formatted_url}" type="video/mp4"> 您的浏览器不支持 HTML5 video 标签。 </video>|
            else
              full_match
            end
          end
          
          # 处理单独的img标签指向MP4的情况
          doc.content = doc.content.gsub(/(<img\s+[^>]*src=["']([^"']*\.mp4)["'][^>]*>)/mi) do |match|
            full_match = $1
            img_src = $2
            
            # 确保路径以/开头
            formatted_url = ensure_leading_slash(img_src)
            
            if is_local_file?(img_src)
              %Q|<video controls width="100%"> <source src="#{formatted_url}" type="video/mp4"> 您的浏览器不支持 HTML5 video 标签。 </video>|
            else
              full_match
            end
          end
          
          # 处理Markdown风格的MP4链接
          doc.content = doc.content.gsub(/(!\[([^\]]*)\]\(([^)]*\.mp4(?:\?[^\s)]*)?)\))/mi) do |match|
            full_match = $1
            video_src = $3
            
            # 确保路径以/开头
            formatted_url = ensure_leading_slash(video_src)
            
            if is_local_file?(video_src)
              %Q|<video controls width="100%"> <source src="#{formatted_url}" type="video/mp4"> 您的浏览器不支持 HTML5 video 标签。 </video>|
            else
              full_match
            end
          end
          
          # 处理Obsidian风格的内部链接
          doc.content = doc.content.gsub(/(!\[\[(.*?\.mp4)(?:\|(.*?))?\]\])/mi) do |match|
            full_match = $1
            file_path = $2
            
            # 确保路径以/开头
            formatted_url = ensure_leading_slash(file_path)
            
            if is_local_file?(file_path)
              %Q|<video controls width="100%"> <source src="#{formatted_url}" type="video/mp4"> 您的浏览器不支持 HTML5 video 标签。 </video>|
            else
              full_match
            end
          end
          
          # 如果内容发生变化，记录一下
          if original_content != doc.content
            puts "VideoConverter: 转换了文档 #{doc.relative_path} 中的MP4链接"
          end
        end
      end
    end

    private

    def is_local_file?(path)
      path.start_with?('/') || path.start_with?('assets/') || 
      path.include?('images/') || path.include?('media/') ||
      path.include?('attachments/') || path.include?('posts/')
    end
    
    def ensure_leading_slash(path)
      return path if path.start_with?('/')
      "/#{path}"
    end
  end

  # 同时使用钩子在渲染后处理
  Hooks.register [:documents, :pages], :post_render do |doc, payload|
    # 只处理HTML输出
    if doc.output && doc.output.include?('.mp4')
      original_output = doc.output
      
      # 处理a标签包裹img标签的情况
      doc.output = doc.output.gsub(/(<a\s+[^>]*href=["']([^"']*\.mp4)["'][^>]*>\s*<img\s+[^>]*src=["']([^"']*\.mp4)["'][^>]*>\s*<\/a>)/mi) do |match|
        full_match = $1
        href_url = $2
        
        # 确保路径以/开头
        formatted_url = ensure_leading_slash(href_url)
        
        if is_local_file?(href_url)
          %Q|<video controls width="100%"> <source src="#{formatted_url}" type="video/mp4"> 您的浏览器不支持 HTML5 video 标签。 </video>|
        else
          full_match
        end
      end
      
      # 处理单独的img标签指向MP4的情况
      doc.output = doc.output.gsub(/(<img\s+[^>]*src=["']([^"']*\.mp4)["'][^>]*>)/mi) do |match|
        full_match = $1
        img_src = $2
        
        # 确保路径以/开头
        formatted_url = ensure_leading_slash(img_src)
        
        if is_local_file?(img_src)
          %Q|<video controls width="100%"> <source src="#{formatted_url}" type="video/mp4"> 您的浏览器不支持 HTML5 video 标签。 </video>|
        else
          full_match
        end
      end
      
      # 处理Markdown风格的MP4链接
      doc.output = doc.output.gsub(/(!\[([^\]]*)\]\(([^)]*\.mp4(?:\?[^\s)]*)?)\))/mi) do |match|
        full_match = $1
        video_src = $3
        
        # 确保路径以/开头
        formatted_url = ensure_leading_slash(video_src)
        
        if is_local_file?(video_src)
          %Q|<video controls width="100%"> <source src="#{formatted_url}" type="video/mp4"> 您的浏览器不支持 HTML5 video 标签。 </video>|
        else
          full_match
        end
      end
      
      # 处理Obsidian风格的内部链接
      doc.output = doc.output.gsub(/(!\[\[(.*?\.mp4)(?:\|(.*?))?\]\])/mi) do |match|
        full_match = $1
        file_path = $2
        
        # 确保路径以/开头
        formatted_url = ensure_leading_slash(file_path)
        
        if is_local_file?(file_path)
          %Q|<video controls width="100%"> <source src="#{formatted_url}" type="video/mp4"> 您的浏览器不支持 HTML5 video 标签。 </video>|
        else
          full_match
        end
      end
      
      # 如果内容发生变化，记录一下
      if original_output != doc.output
        puts "VideoConverter(post_render): 转换了 #{doc.id} 中的MP4链接"
      end
    end
    
    doc # 返回文档对象
  end

  def self.is_local_file?(path)
    path.start_with?('/') || path.start_with?('assets/') || 
    path.include?('images/') || path.include?('media/') ||
    path.include?('attachments/') || path.include?('posts/')
  end
  
  def self.ensure_leading_slash(path)
    return path if path.start_with?('/')
    "/#{path}"
  end
end