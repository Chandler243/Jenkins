#!/usr/bin/env ruby
#encoding: utf-8
require 'mumble-ruby'
require 'ruby-mpd'
require 'cinch'
require 'colorize'

HOST = 'localhost'
PORT = '6600'
mpd = MPD.new(HOST,PORT, {callbacks: true})
begin
        mpd.connect
        mpd.password('chandler243')
    puts "Woot! Successfully linked to MPD"
rescue
        puts "Oh, crap. Looks like we couldn't communicate with the MPD server at #{HOST}:#{PORT}."
end

# No longer needed. Legacy code.
# cli = Mumble::Client.new('node.chandlershax.com', 64738, 'Jenkins')

Mumble.configure do |conf|
        conf.sample_rate = 48000
        conf.bitrate = 32000
end

cli = Mumble::Client.new('localhost') do |conf|
        conf.username = 'Jenkins'
end


bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.freenode.org"
    c.channels = ["#ChandlersHax"]
  end

  on :message, "hello" do |m|
    m.reply "Hello, #{m.user.nick}"
    $channel = cli.me.channel_id
  end
end


cli.connect
sleep(1)

stream = cli.stream_raw_audio('/tmp/mumble.fifo')
stream.volume = 10
$vol = 10
VERSION = 0.2
CHILL = false
SHUFFLE = true
$channel = cli.me.channel_id
cli.text_channel($channel,"Jenkins Version #{VERSION} Successfully Initialized.")
YT = "null"

mpd.on :song do |song|
        song = mpd.current_song
        puts "Hey, look! We are now playing #{song.file}"
end

cli.on_text_message do |msg|
        $channel = cli.me.channel_id
        song = mpd.current_song
        case msg.message
        when "!skip"
                mpd.next
                song = mpd.current_song
            cli.text_channel($channel,"Song skipped, now playing: #{song.file}")
        when "!stats"
                stats = `mpc --host chandler243@localhost stats`
                cli.text_channel($channel,stats)
        when "!reset"
                exec("./jenkins.rb")
        when "!next"
                $channel = cli.me.channel_id
                print("Coming up: #{mpd.queue(1..10)}")
        when "!help"
                cli.text_channel($channel, "<br><center><strong>Jenkins Commands</strong></center>
                        <dl>
                        <dt>Volume</dt>
                        <dd> - Run the commands !volUp and !volDown to adjust volume</dd>
                        <dt>Playback</dt>
                        <dd> - Use !skip and !toggle to modify playback</dd>
                        <dt>Regular Playback</dt>
                        <dd> - You can resume normal playback at any time by typing !resume</dd>
                        <dt>Chill Out</dt>
                        <dd> - Want to kick back and relax? Run !chill to load up a chill playlist</dd>
                        <dt>Praise Gaben</dt>
                        <dd> - Want to praise our dear lord Gaben? Run !gaben to load up songs for our glorious master.</dd>
                        <dt>Status</dt>
                        <dd> - Looking for the current status of the bot? Run this to get detailed information</dd>
                        </dl>
                <strong>ChandlersHax - 2/26/14</strong>")
        when "!toggle"
                system 'mpc --host chandler243@localhost toggle'
        when "!gaben"
                system 'mpc --host chandler243@localhost clear && mpc --host chandler243@localhost load gaben && mpc --host chandler243@localhost play'
                # mpd.clear
                # mpd.playlist.load('gaben')
                # mpd.play
                cli.text_channel($channel,"work it ᕙ༼ຈل͜ຈ༽ᕗ harder")
                cli.text_channel($channel,"make it (ง •̀_•́)ง better")
                cli.text_channel($channel,"do it ᕦ༼ຈل͜ຈ༽ᕤ faster")
                cli.text_channel($channel,"raise ur ヽ༼ຈل͜ຈ༽ﾉ donger")
        when "!ateam"
                system 'mpc --host chandler243@localhost clear && mpc --host chandler243@localhost load ateam && mpc --host chandler243@localhost play'
                cli.text_channel($channel,"ALL HAIL BASED RICK!!!!")
        when "!chill"
                system 'mpc --host chandler243@localhost clear && mpc --host chandler243@localhost load chill && mpc --host chandler243@localhost random on && mpc --host chandler243@localhost play'
            song = `mpc --host chandler243@localhost current`
            cli.text_channel($channel,'You''re now chilling out, starting with ' + song)
        when "!resume"
                system 'mpc --host chandler243@localhost clear && mpc --host chandler243@localhost load derp && mpc --host chandler243@localhost random on && mpc --host chandler243@localhost play'
            song = `mpc --host chandler243@localhost current`
                cli.text_channel($channel, "Now resuming normal playback, starting off with " + song)
        when "!loop"
                system 'mpc --host chandler243@localhost repeat'
        when "!playliststat"
                playliststat = `mpc --host chandler243@localhost playlist`
            cli.text_channel($channel,playliststat)
        when "!status"
                status = `mpc --host chandler243@localhost`
            cli.text_channel($channel,status)
        when "!song"
                song = `mpc --host chandler243@localhost current`
            cli.text_channel($channel,song + "Now get back to playing polo.")
        when "!bigqueue"
                cli.text_channel($channel,"Please standby, recompiling the queue...")
                system "mpc --host chandler243@localhost clear"
                system "mpc --host chandler243@localhost update"
                system "mpc --host chandler243@localhost listall | mpc --host chandler243@localhost add"
                sleep(2)
                system "mpc --host chandler243@localhost play"
                cli.text_channel($channel,"Finished compiling the queue. All songs added. Enjoy!")
        when "!shuffle" #Toggle Shuffle Status
                if SHUFFLE == true
                        cli.text_channel($channel, "Now shuffling songs, !shuffle again to stop.")
                        system `mpc --host chandler243@localhost random on`
                        SHUFFLE = !SHUFFLE
                else
                   cli.text_channel($channel, "No longer shuffling songs. !shuffle to start again.")
                        system `mpc --host chandler243@localhost random off`
                        SHUFFLE = !SHUFFLE
                end
        else
                 if /!yt./.match(msg.message)
                    YT = msg.message
                    print(YT)
                    YT = YT[4, 100]
                    system "youtube-dl --extract-audio --audio-format mp3 --no-playlist -o '/var/lib/mpd/music/mumbledownload/%(title)s.%(ext)s' #{YT}"
                    cli.text_channel($channel, "The video located at #{YT} has been successfully downloaded and converted!")
                 elsif /!sc./.match(msg.message)
                        SC = msg.message
                        print(SC)
                        SC = SC[4,100]
                        system "./scdl.sh #{SC}"
                        cli.text_channel($channel, "The song(s) located at #{SC} has been successfully downloaded and converted!")
                 elsif /!vol./.match(msg.message)
                        $vol = msg.message
                        $vol = $vol[5,100]
                        $vol = $vol.to_i
                        stream.volume = $vol
                 else
                        print("Diagnostic Message:".yellow + "Non-command message was sent in the channel. Ignoring.\n")
                 end
        end
end


puts "\e[H\e[2J"
print "Jenkins revision #{VERSION} is now properly loaded. Press enter to force shutdown.\n".green;
gets
cli.disconnect
