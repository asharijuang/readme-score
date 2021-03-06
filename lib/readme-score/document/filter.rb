module ReadmeScore
  class Document
    class Filter
      SERVICES = ["travis-ci.org", "codeclimate.com", "gemnasium.com", "cocoadocs.org", "readme-score-api.herokuapp.com"]

      def initialize(noko_or_html)
        @noko = Util.to_noko(noko_or_html, true)
      end

      def filtered_html!
        remove_license!
        remove_contact!
        remove_service_images!

        @noko.to_s
      end

      def remove_license!
        remove_heading_sections_named("license")
        remove_heading_sections_named("licensing")
        remove_heading_sections_named("copyright")
      end

      def remove_contact!
        remove_heading_sections_named("contact")
        remove_heading_sections_named("author")
        remove_heading_sections_named("credits")
      end

      def remove_service_images!
        SERVICES.each {|service|
          remove_anchor_images_containing_url(service)
        }
      end

      private
        def remove_heading_sections_named(prefix)
          any_hit = false
          selectors = (1..5).map {|i| "h#{i}"}
          selectors.each { |h|
            @noko.search(h).each { |heading|
              if heading.content.downcase == prefix
                # hit - remove everything until the next heading
                while sibling = heading.next_sibling
                  if sibling.name.downcase.start_with?(heading.name)
                    break
                  else
                    sibling.remove
                  end
                end
                heading.remove
                any_hit = true
                break
              end
            }
          }
          any_hit
        end

        def remove_anchor_images_containing_url(url_fragment)
          @noko.search('a').each {|a|
            href = a['href']
            if href && href.downcase.include?(url_fragment.downcase)
              a.remove unless a.search('img').empty?
            end
          }
        end
    end
  end
end