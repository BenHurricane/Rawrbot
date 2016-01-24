require 'plugins/Karma'

def delete_key_from_db(db, key)
  db.execute('DELETE FROM karma WHERE key=?', key)
  expect(db.get_first_value('SELECT val FROM karma WHERE key=?', key)).to eq nil
end

def set_db_key_value(db, key, val)
  delete_key_from_db(db, key)
  db.execute('INSERT INTO karma (key,val) VALUES (?,?)', key, val)
  expect(db.get_first_value('SELECT val FROM karma WHERE key=?', key)).to eq val
end

RSpec.describe 'Karma' do
  before(:each) do
    @bot = make_bot
    @bot.loggers.level = :error
    @bot.plugins.register_plugin(Karma)
  end

  let(:db) { 'karma.sqlite3' }
  let(:karma_key) { 'imatestkey' }

  context 'key does not have a karma value' do
    before(:each) do
      # TODO: refactor Karma plugin so we can use a test-only db here
      delete_key_from_db(SQLite3::Database.new(db), karma_key)
    end

    it 'shows karma as neutral' do
      msg = make_message(@bot, "!karma #{karma_key}", channel: '#testchan')
      expect(get_replies(msg).length).to eq 1
      expect(get_replies(msg)[0].text).to eq "#{karma_key} has neutral karma."
    end
    it 'shows karma as 1 after incrementing' do
      msg = make_message(@bot, "#{karma_key}++", channel: '#testchan')
      expect(get_replies(msg).length).to eq 0
      msg = make_message(@bot, "!karma #{karma_key}", channel: '#testchan')
      expect(get_replies(msg).length).to eq 1
      expect(get_replies(msg)[0].text).to eq "#{karma_key} has karma of 1."
    end
    it 'shows karma as -1 after decrementing' do
      msg = make_message(@bot, "#{karma_key}--", channel: '#testchan')
      expect(get_replies(msg).length).to eq 0
      msg = make_message(@bot, "!karma #{karma_key}", channel: '#testchan')
      expect(get_replies(msg).length).to eq 1
      expect(get_replies(msg)[0].text).to eq "#{karma_key} has karma of -1."
    end
  end

  context 'key has an existing karma value of -1' do
    let(:karma_value) { -1 }

    before(:each) do
      # TODO: refactor Karma plugin so we can use a test-only db here
      set_db_key_value(SQLite3::Database.new(db), karma_key, karma_value)
    end

    it 'shows existing karma value' do
      msg = make_message(@bot, "!karma #{karma_key}", channel: '#testchan')
      expect(get_replies(msg).length).to eq 1
      expect(get_replies(msg)[0].text).to eq "#{karma_key} has karma of #{karma_value}."
    end
    it 'shows karma as neutral after incrementing' do
      msg = make_message(@bot, "#{karma_key}++", channel: '#testchan')
      expect(get_replies(msg).length).to eq 0
      msg = make_message(@bot, "!karma #{karma_key}", channel: '#testchan')
      expect(get_replies(msg).length).to eq 1
      expect(get_replies(msg)[0].text).to eq "#{karma_key} has neutral karma."
    end
    it 'shows karma as 1 fewer after decrementing' do
      msg = make_message(@bot, "#{karma_key}--", channel: '#testchan')
      expect(get_replies(msg).length).to eq 0
      msg = make_message(@bot, "!karma #{karma_key}", channel: '#testchan')
      expect(get_replies(msg).length).to eq 1
      expect(get_replies(msg)[0].text).to eq "#{karma_key} has karma of #{karma_value - 1}."
    end
  end

  context 'key has an existing karma value of 1' do
    let(:karma_value) { 1 }

    before(:each) do
      # TODO: refactor Karma plugin so we can use a test-only db here
      set_db_key_value(SQLite3::Database.new(db), karma_key, karma_value)
    end

    it 'shows existing karma value' do
      msg = make_message(@bot, "!karma #{karma_key}", channel: '#testchan')
      expect(get_replies(msg).length).to eq 1
      expect(get_replies(msg)[0].text).to eq "#{karma_key} has karma of #{karma_value}."
    end
    it 'shows karma as 1 more after incrementing' do
      msg = make_message(@bot, "#{karma_key}++", channel: '#testchan')
      expect(get_replies(msg).length).to eq 0
      msg = make_message(@bot, "!karma #{karma_key}", channel: '#testchan')
      expect(get_replies(msg).length).to eq 1
      expect(get_replies(msg)[0].text).to eq "#{karma_key} has karma of #{karma_value + 1}."
    end
    it 'shows karma as neutral after decrementing' do
      msg = make_message(@bot, "#{karma_key}--", channel: '#testchan')
      expect(get_replies(msg).length).to eq 0
      msg = make_message(@bot, "!karma #{karma_key}", channel: '#testchan')
      expect(get_replies(msg).length).to eq 1
      expect(get_replies(msg)[0].text).to eq "#{karma_key} has neutral karma."
    end
  end

  context 'key has an existing karma value that is not 1 or -1' do
    [-9999, -4, 32, 10601].each do |val|
      let(:karma_value) { val }

      before(:each) do
        # TODO: refactor Karma plugin so we can use a test-only db here
        set_db_key_value(SQLite3::Database.new(db), karma_key, karma_value)
      end

      it 'shows existing karma value' do
        msg = make_message(@bot, "!karma #{karma_key}", channel: '#testchan')
        expect(get_replies(msg).length).to eq 1
        expect(get_replies(msg)[0].text).to eq "#{karma_key} has karma of #{karma_value}."
      end
      it 'shows karma as 1 more after incrementing' do
        msg = make_message(@bot, "#{karma_key}++", channel: '#testchan')
        expect(get_replies(msg).length).to eq 0
        msg = make_message(@bot, "!karma #{karma_key}", channel: '#testchan')
        expect(get_replies(msg).length).to eq 1
        expect(get_replies(msg)[0].text).to eq "#{karma_key} has karma of #{karma_value + 1}."
      end
      it 'shows karma as 1 fewer after decrementing' do
        msg = make_message(@bot, "#{karma_key}--", channel: '#testchan')
        expect(get_replies(msg).length).to eq 0
        msg = make_message(@bot, "!karma #{karma_key}", channel: '#testchan')
        expect(get_replies(msg).length).to eq 1
        expect(get_replies(msg)[0].text).to eq "#{karma_key} has karma of #{karma_value - 1}."
      end
    end
  end
end
