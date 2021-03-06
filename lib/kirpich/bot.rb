require 'slack'
require 'kirpich/answers'

module Kirpich
  class Bot
    def initialize(config)
      @client = config[:client]
      @answers = config[:answers]
    end

    def post_text(text, data)
      Slack.chat_postMessage as_user: true, channel: data['channel'], text: text
    end

    def on_message(data)
      return if data['user'] == 'U081B2XCP'

      text = select_text(data)
      if text
        post_text text, data
      end
    end

    def select_text(data)
      text = ''

      begin
        if data['text'] =~ /(сред|^(ну и|да и|и) ?похуй)/i
          text = @answers.poh_text
        elsif data['text'] =~ /(зда?о?ров|привет|вечер в хату)/i
          text = @answers.hello_text
        elsif data['text'] =~ /(как дела|что.*?как|чо.*?каво)/i
          text = @answers.ok_text
        elsif data['text'] =~ /^(пашок|пашка|кирпич|паш|пацантре|народ|кто-нибудь|эй|э)/i || data['text'] =~ /(kirpich:|@kirpich:)/ || data['channel'] == 'D081AUUHW'
          text = on_call(data)
        end
      rescue RuntimeError
        text = @answers.do_not_know_text
      end

      text
    end

    def on_call(data)
      if data['text'] =~ /(синька)/i
        text = @answers.sin_text
      elsif data['text'] =~ /(пошли|пошел)/i
        text = @answers.nah_text
      elsif data['text'] =~ /(лох|черт|пидо?р|гей|хуйло|сука|бля|петух)/i
        text = @answers.nah_text
      elsif data['text'] =~ /^(зда?о?ров|привет)/i
        text = @answers.hello_text
      elsif data['text'] =~ /(красава|молодчик)/i
        text = @answers.ok_text
      elsif data['text'] =~ /^материализуй.*/i
        text = @answers.materialize(data['text'])
      elsif data['text'] =~ /(дальше|продолжай|давай еще|еще|следующую)/i
        text = @answers.inferot_next_image
      elsif data['text'] =~ /(титьк|грудь|сисек|сиська|сиськи|сиську|сосок|понедельник)/i
        text = @answers.inferot_image('http://inferot.net/girls/big-tits/')
      elsif data['text'] =~ /(жоп|задниц|попец|вторник)/i
        text = @answers.inferot_image('http://inferot.net/girls/ass/')
      elsif data['text'] =~ /(рыжая|рыжую)/i
        text = @answers.inferot_image('http://inferot.net/girls/red/')
      elsif data['text'] =~ /(кто.*главный)/i
        text = @answers.chef_text
      elsif data['text'] =~ /(картинку|смехуечек|пикчу)/i
        text = @answers.pikabu_image
      elsif data['text'] =~ /(пятница)/i
        text = @answers.brakingmad_text
        text = text, data
      elsif data['text'] =~ /где это/i
        m = data['text'].scan(/где это (.*)/im)
        q = m[0][0]
        text = @answers.geo_search(q)
      elsif data['text'] =~ /курс/i
        text = @answers.currency
      elsif data['text'] =~ /(умеешь|можешь)/i
        text = Kirpich::HELP, data
      elsif data['text'] =~ /(объясни|разъясни|растолкуй|что|как|кто) ?(что|как|кто)? ?(это|эта|такой|такое|такие)? (.*)/i
        m = data['text'].scan(/(объясни|разъясни|растолкуй|что|как|кто) ?(что|как|кто)? ?(это|эта|такой|такое|такие)? (.*)/im)
        if m && m[0] && m[0][3]
          q = m[0][3]
          text = @answers.lurk_search q
        else
          text = @answers.do_not_know_text
        end
      elsif data['text'] =~ /(запость|ебни|пиздани|ебани|постани|постни).*(сереге)/i
        text = @answers.sexcom_image('http://www.sex.com/big-dicks/porn-pics/?sort=latest')
      elsif data['text'] =~ /(запость|ебни|пиздани|ебани|постани|постни)/i
        text = @answers.random_text
      elsif data['text'] =~ /(правила)/i
        text = @answers.rules_text
      elsif data['text'] =~ /(погода)/i
        text = @answers.poh_text
      elsif data['text'] =~ /(надо|можно|да|нет).*?\?/i
        text = @answers.yes_no_text
      elsif data['text'] =~ /выполни.*\(.*?\)/i
        m = data['text'].scan(/выполни.*\((.*?)\)/i)
        if m && m[0][0]
          begin
            text = eval(m[0][0])
          rescue Exception
            text = @answers.do_not_know_text
          end
        end
      else
        text = @answers.call_text
      end
    end

    def on_hello
      #random_post_timer
    end
  end
end
