require 'nokogiri'

module Kirpich
  class Answers
    def materialize(text)
      result = []
      text.split(' ').each do |word|
        if word != 'материализуй'
          result << word

          if word.size > 3 && !(word =~ /[,.:;!?'\"\/#$%^&*()]/) && rand(7) == 5
            result << MEJ.sample
          end
        end
      end

      result.join(' ')
    end

    def sexcom_image(url)
      response = Faraday.get url

      urls = Nokogiri::HTML(response.body).css(".image_wrapper img").map do |src|
        src['data-src']
      end

      urls.sample
    end

    def inferot_image(url)
      response = Faraday.get url

      girl = Nokogiri::HTML(response.body).css(".shortstory").map { |e| e }.sample

      @prev_girl = girl.css('a').first['href']
      girl.css('img').first['src']
    end

    def inferot_next_image
      if @prev_girl
        response = Faraday.get @prev_girl

        @prev_girl = nil

        @images = Nokogiri::HTML(response.body).css(".maincont img").map { |e| e['src'] }
        @images.shift
      elsif @images.any?
        @images.shift
      else
        NO_GIRLS.sample
      end
    end

    def brakingmad_text
      response = Faraday.get 'http://breakingmad.me/ru/'

      txts = Nokogiri::HTML(response.body).css(".news-row").map { |e| e }.sample
      txts = "#{txts.css("h2").first.text}.\n#{txts.css('.news-full-forspecial').first.text}"
      materialize txts
    end

    def pikabu_image
      response = Faraday.get 'http://pikabu.ru/'
      urls = Nokogiri::HTML(response.body).css(".b-story__content_type_media img").map do |src|
        src['src']
      end
      urls.sample
    end

    def pikabu_text
      response = Faraday.get 'http://pikabu.ru/best'

      txts = Nokogiri::HTML(response.body).css(".b-story__content_type_text").map do |src|
        src.text
      end
      materialize txts.sample
    end

    def interfax_text
      response = Faraday.get 'http://www.interfax.ru/'

      txts = Nokogiri::HTML(response.body).css(".text h3").map do |src|
        src.text
      end

      materialize "Молния! #{txts.sample}"
    end

    def currency
      response = Faraday.get "https://query.yahooapis.com/v1/public/yql?q=select+*+from+yahoo.finance.xchange+where+pair+=+%22USDRUB,EURRUB%22&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback="
      result = JSON.parse response.body

      text = result["query"]["results"]["rate"].map do |rate|
        "#{rate["Name"]}: #{rate["Rate"]}"
      end

      text.join("\n")
    end

    def geo_search(q)
      "https://www.google.ru/maps/search/#{q}"
    end

    def chef_text
      Kirpich::GLAV.sample
    end

    def rules_text
      Kirpich::RULES
    end

    def poh_text
      Kirpich::POX.sample
    end

    def do_not_know_text
      Kirpich::HZ.sample
    end

    def obr_text(text, rand)
      if rand(rand) === 0
        text += ", #{Kirpich::OBR.sample}"
      end
    end

    def hello_text
      text = Kirpich::HELLO.sample
      obr_text(text, 3)
    end

    def ok_text
      text = Kirpich::ZBS.sample
      obr_text(text, 2)
    end

    def yes_no_text
      text = YES_NO.sample
      obr_text(text, 3)
    end

    def sin_text
      text = Kirpich::SIN.sample
      obr_text(text, 2)
    end

    def nah_text
      text = Kirpich::NAX.sample
      obr_text(text, 2)
    end

    def call_text
      text = Kirpich::CALL.sample
      obr_text(text, 4)
    end

    def lurk_search(text)
      return do_not_know_text unless text

      response = Faraday.get "http://lurkmore.to/index.php?title=#{text.strip.gsub(/ /, '_')}"
      md = response.body.scan(/Please.*?\/(.*?)$/im)

      if md && md[0] && md[0][0]
        link = md[0][0]
        response = Faraday.get "http://lurkmore.to/#{link}"
        page = Nokogiri::HTML(response.body)

        images = page.css('img.thumbimage').map { |e| e['src'] }
        if images.any?
          result ||= ''
          result += "#{images.sample.gsub(/^\/\//, 'http://')}\n"
        end

        texts = page.css('#bodyContent>p').map { |e| e.text }

        if texts.any?
          result ||= ''
          result += "#{texts[0]}\n"
          result += "#{texts[1]}\n" if texts.length > 1
        end
      end

      result = do_not_know_text unless result

      if rand(4) == 0
        result += "\nВот так вот, #{Kirpich::OBR.sample}"
      end

      result
    end
  end
end
