/*
* Copyright (c) 2005-2016, BearWare.dk
*
* Contact Information:
*
* Bjoern D. Rasmussen
* Kirketoften 5
* DK-8260 Viby J
* Denmark
* Email: contact@bearware.dk
* Phone: +45 20 20 54 59
* Web: http://www.bearware.dk
*
* This source code is part of the TeamTalk 5 SDK owned by
* BearWare.dk. All copyright statements may not be removed
* or altered from any source distribution. If you use this
* software in a product, an acknowledgment in the product
* documentation is required.
*
*/

import UIKit
import AVFoundation

let PREF_NICKNAME = "nickname_preference"
let PREF_JOINROOTCHANNEL = "joinroot_preference"
let PREF_GENERAL_PTTLOCK = "general_pttlock_preference"

let PREF_DISPLAY_SHOWUSERNAME = "display_showusername_preference"
let PREF_DISPLAY_PROXIMITY = "display_proximity_sensor"
let PREF_DISPLAY_POPUPTXTMSG = "display_popuptxtmsg_preference"
let PREF_DISPLAY_LIMITTEXT = "display_limittext_preference"
let PREF_DISPLAY_PUBSERVERS = "display_publicservers_preference"

let PREF_MASTER_VOLUME = "mastervolume_preference"
let PREF_MICROPHONE_GAIN = "microphonegain_preference"
let PREF_SPEAKER_OUTPUT = "speakeroutput_preference"
let PREF_VOICEACTIVATION = "voiceactivationlevel_preference"
let PREF_MEDIAFILE_VOLUME = "mediafile_volume_preference"
let PREF_HEADSET_TXTOGGLE = "headset_tx_preferences"
let PREF_VOICEPROCESSINGIO = "voiceprocessing_preference"

let PREF_SNDEVENT_SERVERLOST = "snd_srvlost_preference"
let PREF_SNDEVENT_VOICETX = "snd_voicetx_preference"
let PREF_SNDEVENT_CHANMSG = "snd_chanmsg_preference"
let PREF_SNDEVENT_USERMSG = "snd_usermsg_preference"
let PREF_SNDEVENT_JOINEDCHAN = "snd_joinedchan_preference"
let PREF_SNDEVENT_LEFTCHAN = "snd_leftchan_preference"

let PREF_SUB_USERMSG = "sub_usertextmsg_preference"
let PREF_SUB_CHANMSG = "sub_chantextmsg_preference"
let PREF_SUB_BROADCAST = "sub_broadcastmsg_preference"
let PREF_SUB_VOICE = "sub_voice_preference"
let PREF_SUB_VIDEOCAP = "sub_videocapture_preference"
let PREF_SUB_MEDIAFILE = "sub_mediafile_preference"
let PREF_SUB_DESKTOP = "sub_desktop_preference"
let PREF_SUB_DESKTOPINPUT = "sub_desktopinput_preference"

let PREF_TTSEVENT_VOICEID = "tts_voiceid_preference"
let PREF_TTSEVENT_VOICELANG = "tts_voicelang_preference"
let PREF_TTSEVENT_JOINEDCHAN = "tts_joinedchan_preference"
let PREF_TTSEVENT_LEFTCHAN = "tts_leftchan_preference"
let PREF_TTSEVENT_CONLOST = "tts_conlost_preference"
let PREF_TTSEVENT_TEXTMSG = "tts_usertxtmsg_preference"
let PREF_TTSEVENT_CHANTEXTMSG = "tts_chantxtmsg_preference"
let PREF_TTSEVENT_RATE = "tts_rate_preference"
let PREF_TTSEVENT_VOL = "tts_volume_preference"


class PreferencesViewController : UIViewController, UITableViewDataSource,
    UITableViewDelegate, UITextFieldDelegate, TeamTalkEvent {
    
    @IBOutlet weak var tableView: UITableView!
   
    var nicknamefield : UITextField?
    
    var users = Set<INT32>()
    
    var limittextcell : UITableViewCell?
    var mastervolcell : UITableViewCell?
    var voiceactcell : UITableViewCell?
    var microphonecell : UITableViewCell?
    var ttsratecell : UITableViewCell?
    var ttsvolcell : UITableViewCell?

    var general_items = [UITableViewCell]()
    var display_items = [UITableViewCell]()
    var soundevents_items = [UITableViewCell]()
    var sound_items  = [UITableViewCell]()
    var subscription_items = [UITableViewCell]()
    var connection_items = [UITableViewCell]()
    var ttsevents_items = [UITableViewCell]()
    var version_items = [UITableViewCell]()
    
    let SECTION_GENERAL = 0,
        SECTION_DISPLAY = 1,
        SECTION_SOUND = 2,
        SECTION_SOUNDEVENTS = 3,
        SECTION_TTSEVENTS = 4,
        SECTION_CONNECTION = 5,
        SECTION_SUBSCRIPTIONS = 6,
        SECTION_VERSION = 7,
        SECTIONS_COUNT = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let settings = NSUserDefaults.standardUserDefaults()
        
        var nickname = settings.stringForKey(PREF_NICKNAME)
        if nickname == nil {
            nickname = DEFAULT_NICKNAME
        }
        
        // general items
        
        let nicknamecell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        nicknamefield = newTableCellTextField(nicknamecell, label: NSLocalizedString("Nickname", comment: "preferences"), initial: nickname!)
        nicknamecell.detailTextLabel!.text = NSLocalizedString("Name displayed in channel list", comment: "preferences")
        nicknamefield?.addTarget(self, action: #selector(PreferencesViewController.nicknameChanged(_:)), forControlEvents: .EditingDidEnd)
        nicknamefield?.delegate = self
        general_items.append(nicknamecell)
        
        let pttlock = settings.objectForKey(PREF_GENERAL_PTTLOCK) != nil && settings.boolForKey(PREF_GENERAL_PTTLOCK)
        let pttlockcell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let pttlockswitch = newTableCellSwitch(pttlockcell, label: NSLocalizedString("Push to Talk lock", comment: "preferences"), initial: pttlock)
        pttlockcell.detailTextLabel!.text = NSLocalizedString("Double tap to lock TX button", comment: "preferences")
        pttlockswitch.addTarget(self, action: #selector(PreferencesViewController.pttlockChanged(_:)), forControlEvents: .ValueChanged)
        general_items.append(pttlockcell)
        
        // display items

        let proximitycell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let proximity = settings.objectForKey(PREF_DISPLAY_PROXIMITY) != nil && settings.boolForKey(PREF_DISPLAY_PROXIMITY)
        let proximitywitch = newTableCellSwitch(proximitycell, label: NSLocalizedString("Proximity sensor", comment: "preferences"), initial: proximity)
        proximitycell.detailTextLabel!.text = NSLocalizedString("Turn off screen when holding phone near ear", comment: "preferences")
        proximitywitch.addTarget(self, action: #selector(PreferencesViewController.proximityChanged(_:)), forControlEvents: .ValueChanged)
        display_items.append(proximitycell)
        
        let txtmsgpopcell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let txtmsgpopup = settings.objectForKey(PREF_DISPLAY_POPUPTXTMSG) == nil || settings.boolForKey(PREF_DISPLAY_POPUPTXTMSG)
        let txtmsgswitch = newTableCellSwitch(txtmsgpopcell, label: NSLocalizedString("Show text messages instantly", comment: "preferences"), initial: txtmsgpopup)
        txtmsgpopcell.detailTextLabel!.text = NSLocalizedString("Pop up text message when new messages are received", comment: "preferences")
        txtmsgswitch.addTarget(self, action: #selector(PreferencesViewController.showtextmessagesChanged(_:)), forControlEvents: .ValueChanged)
        display_items.append(txtmsgpopcell)
        
        limittextcell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let limittext = settings.objectForKey(PREF_DISPLAY_LIMITTEXT) == nil ? DEFAULT_LIMIT_TEXT : settings.integerForKey(PREF_DISPLAY_LIMITTEXT)
        let limittextstepper = newTableCellStepper(limittextcell!, label: NSLocalizedString("Maximum Text Length", comment: "preferences"), min: 1, max: Double(TT_STRLEN-1), step: 1, initial: Double(limittext))
        limittextChanged(limittextstepper)
        limittextstepper.addTarget(self, action: #selector(PreferencesViewController.limittextChanged(_:)), forControlEvents: .ValueChanged)
        display_items.append(limittextcell!)
        
        let pubservercell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let pubsrv = settings.objectForKey(PREF_DISPLAY_PUBSERVERS) == nil || settings.boolForKey(PREF_DISPLAY_PUBSERVERS)
        let pubserverswitch = newTableCellSwitch(pubservercell, label: NSLocalizedString("Show Public Servers", comment: "preferences"), initial: pubsrv)
        pubservercell.detailTextLabel!.text = NSLocalizedString("Show public servers in server list", comment: "preferences")
        pubserverswitch.addTarget(self, action: #selector(PreferencesViewController.showpublicserversChanged(_:)), forControlEvents: .ValueChanged)
        display_items.append(pubservercell)

        let showusernamecell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let showusername = settings.objectForKey(PREF_DISPLAY_SHOWUSERNAME) != nil && settings.boolForKey(PREF_DISPLAY_SHOWUSERNAME)
        let showusernameswitch = newTableCellSwitch(showusernamecell, label: NSLocalizedString("Show usernames", comment: "preferences"), initial: showusername)
        showusernamecell.detailTextLabel!.text = NSLocalizedString("Show usernames instead of nicknames", comment: "preferences")
        showusernameswitch.addTarget(self, action: #selector(PreferencesViewController.showusernameChanged(_:)), forControlEvents: .ValueChanged)
        display_items.append(showusernamecell)
        
        
        // sound preferences
        
        mastervolcell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        var outputvol = Int(SOUND_VOLUME_DEFAULT.rawValue)
        if ttInst != nil {
            outputvol = Int(TT_GetSoundOutputVolume(ttInst))
        }
        else if settings.objectForKey(PREF_MASTER_VOLUME) != nil {
            let output_pct = settings.integerForKey(PREF_MASTER_VOLUME)
            outputvol = refVolume(Double(output_pct))
        }
        let output_pct = refVolumeToPercent(outputvol)
        let mastervolslider = newTableCellSlider(mastervolcell!, label: NSLocalizedString("Master Volume", comment: "preferences"), min: 0, max: 1, initial: Float(output_pct) / 100)
        mastervolslider.addTarget(self, action: #selector(PreferencesViewController.masterVolumeChanged(_:)), forControlEvents: .ValueChanged)
        masterVolumeChanged(mastervolslider)
        sound_items.append(mastervolcell!)
        
        let mfvolumecell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        var mfvol = DEFAULT_MEDIAFILE_VOLUME
        if settings.valueForKey(PREF_MEDIAFILE_VOLUME) != nil {
            mfvol = settings.floatForKey(PREF_MEDIAFILE_VOLUME)
        }
        let mfvolumeslider = newTableCellSlider(mfvolumecell, label: NSLocalizedString("Media File Volume", comment: "preferences"), min: 0, max: 1, initial: mfvol)
        mfvolumeslider.addTarget(self, action: #selector(PreferencesViewController.mediafileVolumeChanged(_:)), forControlEvents: .ValueChanged)
        mfvolumecell.detailTextLabel?.text = NSLocalizedString("Media file vs. voice volume", comment: "preferences")
        sound_items.append(mfvolumecell)

        microphonecell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        var inputvol = Int(SOUND_GAIN_DEFAULT.rawValue)
        if ttInst != nil {
            inputvol = Int(TT_GetSoundInputGainLevel(ttInst))
        }
        else if settings.objectForKey(PREF_MICROPHONE_GAIN) != nil {
            let input_pct = settings.integerForKey(PREF_MICROPHONE_GAIN)
            inputvol = refVolume(Double(input_pct))
        }
        let input_pct = refVolumeToPercent(inputvol)
        let microphoneslider = newTableCellSlider(microphonecell!, label: NSLocalizedString("Microphone Gain", comment: "preferences"), min: 0, max: 1, initial: Float(input_pct) / 100)
        microphoneslider.addTarget(self, action: #selector(PreferencesViewController.microphoneGainChanged(_:)), forControlEvents: .ValueChanged)
        microphoneGainChanged(microphoneslider)
        sound_items.append(microphonecell!)
        
        // use SOUND_VU_MAX + 1 as voice activation disabled
        var voiceact = VOICEACT_DISABLED
        if settings.objectForKey(PREF_VOICEACTIVATION) != nil {
            voiceact = settings.integerForKey(PREF_VOICEACTIVATION)
        }
        voiceactcell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let voiceactslider = newTableCellSlider(voiceactcell!, label: NSLocalizedString("Voice Activation Level", comment: "preferences"),
            min: 0, max: 1, initial: Float(voiceact) / Float(VOICEACT_DISABLED))
        voiceactslider.addTarget(self, action: #selector(PreferencesViewController.voiceactlevelChanged(_:)), forControlEvents: .ValueChanged)
        voiceactlevelChanged(voiceactslider)
        sound_items.append(voiceactcell!)
        
        let speakercell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let speakerswitch = newTableCellSwitch(speakercell, label: NSLocalizedString("Speaker Output", comment: "preferences"),
            initial: settings.objectForKey(PREF_SPEAKER_OUTPUT) != nil && settings.boolForKey(PREF_SPEAKER_OUTPUT))
        speakercell.detailTextLabel!.text = NSLocalizedString("Use iPhone's speaker instead of earpiece", comment: "preferences")
        speakerswitch.addTarget(self, action: #selector(PreferencesViewController.speakeroutputChanged(_:)), forControlEvents: .ValueChanged)
        sound_items.append(speakercell)
        
        let headsettxcell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let headsettxswitch = newTableCellSwitch(headsettxcell, label: NSLocalizedString("Headset TX Toggle", comment: "preferences"),
            initial: settings.objectForKey(PREF_HEADSET_TXTOGGLE) == nil || settings.boolForKey(PREF_HEADSET_TXTOGGLE))
        headsettxcell.detailTextLabel!.text = NSLocalizedString("Toggle voice transmission using headset", comment: "preferences")
        headsettxswitch.addTarget(self, action: #selector(PreferencesViewController.headsetTxToggleChanged(_:)), forControlEvents: .ValueChanged)
        sound_items.append(headsettxcell)
        
        let voice_prepcell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let voiceprepswitch = newTableCellSwitch(voice_prepcell, label: NSLocalizedString("Voice Preprocessing", comment: "preferences"),
            initial: settings.objectForKey(PREF_VOICEPROCESSINGIO) != nil && settings.boolForKey(PREF_VOICEPROCESSINGIO))
        voice_prepcell.detailTextLabel!.text = NSLocalizedString("Use echo cancellation and automatic gain control",
                                                                 comment: "preferences")
        voiceprepswitch.addTarget(self, action: #selector(PreferencesViewController.voicepreprocessingChanged(_:)), forControlEvents: .ValueChanged)
        sound_items.append(voice_prepcell)
        
        
        // sound events
        
        let srvlostcell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let srvlostswitch = newTableCellSwitch(srvlostcell, label: NSLocalizedString("Server Connection Lost", comment: "preferences"), initial: getSoundFile(.SRV_LOST) != nil)
        srvlostcell.detailTextLabel!.text = NSLocalizedString("Play sound when connection is dropped", comment: "preferences")
        srvlostswitch.tag = Sounds.SRV_LOST.rawValue
        srvlostswitch.addTarget(self, action: #selector(PreferencesViewController.soundeventChanged(_:)), forControlEvents: .ValueChanged)
        soundeventChanged(srvlostswitch)
        soundevents_items.append(srvlostcell)
        
        let voicetxcell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let voicetxswitch = newTableCellSwitch(voicetxcell, label: NSLocalizedString("Voice Transmission Toggled", comment: "preferences"), initial: getSoundFile(.TX_ON) != nil)
        voicetxcell.detailTextLabel!.text = NSLocalizedString("Play sound when voice transmission is toggled", comment: "preferences")
        voicetxswitch.tag = Sounds.TX_ON.rawValue
        voicetxswitch.addTarget(self, action: #selector(PreferencesViewController.soundeventChanged(_:)), forControlEvents: .ValueChanged)
        soundeventChanged(voicetxswitch)
        soundevents_items.append(voicetxcell)

        let usermsgcell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let usermsgswitch = newTableCellSwitch(usermsgcell, label: NSLocalizedString("Private Text Message", comment: "preferences"), initial: getSoundFile(.USER_MSG) != nil)
        usermsgcell.detailTextLabel!.text = NSLocalizedString("Play sound when private text message is received", comment: "preferences")
        usermsgswitch.tag = Sounds.USER_MSG.rawValue
        usermsgswitch.addTarget(self, action: #selector(PreferencesViewController.soundeventChanged(_:)), forControlEvents: .ValueChanged)
        soundeventChanged(usermsgswitch)
        soundevents_items.append(usermsgcell)
        
        let chanmsgcell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let chanmsgswitch = newTableCellSwitch(chanmsgcell, label: NSLocalizedString("Channel Text Message", comment: "preferences"), initial: getSoundFile(.CHAN_MSG) != nil)
        chanmsgcell.detailTextLabel!.text = NSLocalizedString("Play sound when channel text message is received", comment: "preferences")
        chanmsgswitch.tag = Sounds.CHAN_MSG.rawValue
        chanmsgswitch.addTarget(self, action: #selector(PreferencesViewController.soundeventChanged(_:)), forControlEvents: .ValueChanged)
        soundeventChanged(chanmsgswitch)
        soundevents_items.append(chanmsgcell)
        
        let joinedchancell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let joinedchanswitch = newTableCellSwitch(joinedchancell, label: NSLocalizedString("User Joins Channel", comment: "preferences"), initial: getSoundFile(.JOINED_CHAN) != nil)
        joinedchancell.detailTextLabel!.text = NSLocalizedString("Play sound when a user joins the channel", comment: "preferences")
        joinedchanswitch.tag = Sounds.JOINED_CHAN.rawValue
        joinedchanswitch.addTarget(self, action: #selector(PreferencesViewController.soundeventChanged(_:)), forControlEvents: .ValueChanged)
        soundeventChanged(joinedchanswitch)
        soundevents_items.append(joinedchancell)
        
        let leftchancell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let leftchanswitch = newTableCellSwitch(leftchancell, label: NSLocalizedString("User Leaves Channel", comment: "preferences"), initial: getSoundFile(.LEFT_CHAN) != nil)
        leftchancell.detailTextLabel!.text = NSLocalizedString("Play sound when a user leaves the channel", comment: "preferences")
        leftchanswitch.tag = Sounds.LEFT_CHAN.rawValue
        leftchanswitch.addTarget(self, action: #selector(PreferencesViewController.soundeventChanged(_:)), forControlEvents: .ValueChanged)
        soundeventChanged(leftchanswitch)
        soundevents_items.append(leftchancell)

        // connection items
        
        let joinroot = settings.objectForKey(PREF_JOINROOTCHANNEL) == nil || settings.boolForKey(PREF_JOINROOTCHANNEL)
        let joinrootcell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let joinrootswitch = newTableCellSwitch(joinrootcell, label: NSLocalizedString("Join Root Channel", comment: "preferences"), initial: joinroot)
        joinrootcell.detailTextLabel!.text = NSLocalizedString("Join root channel after login", comment: "preferences")
        joinrootswitch.addTarget(self, action: #selector(PreferencesViewController.joinrootChanged(_:)), forControlEvents: .ValueChanged)
        connection_items.append(joinrootcell)
        
        // subscription items
        
        let subs = getDefaultSubscriptions()

        let subusermsgcell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let subusermsgswitch = newTableCellSwitch(subusermsgcell, label: NSLocalizedString("User Messages", comment: "preferences"), initial: (subs & SUBSCRIBE_USER_MSG.rawValue) != 0)
        subusermsgcell.detailTextLabel!.text = NSLocalizedString("Receive text messages by default", comment: "preferences")
        subusermsgswitch.tag = Int(SUBSCRIBE_USER_MSG.rawValue)
        subusermsgswitch.addTarget(self, action: #selector(PreferencesViewController.subscriptionChanged(_:)), forControlEvents: .ValueChanged)
        subscription_items.append(subusermsgcell)
        
        let subchanmsgcell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let subchanmsgswitch = newTableCellSwitch(subchanmsgcell, label: NSLocalizedString("Channel Messages", comment: "preferences"), initial: (subs & SUBSCRIBE_CHANNEL_MSG.rawValue) != 0)
        subchanmsgcell.detailTextLabel!.text = NSLocalizedString("Receive channel messages by default", comment: "preferences")
        subchanmsgswitch.tag = Int(SUBSCRIBE_CHANNEL_MSG.rawValue)
        subchanmsgswitch.addTarget(self, action: #selector(PreferencesViewController.subscriptionChanged(_:)), forControlEvents: .ValueChanged)
        subscription_items.append(subchanmsgcell)
        
        let subbcastmsgcell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let subbcastmsgswitch = newTableCellSwitch(subbcastmsgcell, label: NSLocalizedString("Broadcast Messages", comment: "preferences"), initial: (subs & SUBSCRIBE_BROADCAST_MSG.rawValue) != 0)
        subbcastmsgcell.detailTextLabel!.text = NSLocalizedString("Receive broadcast messages by default", comment: "preferences")
        subbcastmsgswitch.tag = Int(SUBSCRIBE_BROADCAST_MSG.rawValue)
        subbcastmsgswitch.addTarget(self, action: #selector(PreferencesViewController.subscriptionChanged(_:)), forControlEvents: .ValueChanged)
        subscription_items.append(subbcastmsgcell)

        let subvoicecell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let subvoiceswitch = newTableCellSwitch(subvoicecell, label: NSLocalizedString("Voice", comment: "preferences"), initial: (subs & SUBSCRIBE_VOICE.rawValue) != 0)
        subvoicecell.detailTextLabel!.text = NSLocalizedString("Receive voice streams by default", comment: "preferences")
        subvoiceswitch.tag = Int(SUBSCRIBE_VOICE.rawValue)
        subvoiceswitch.addTarget(self, action: #selector(PreferencesViewController.subscriptionChanged(_:)), forControlEvents: .ValueChanged)
        subscription_items.append(subvoicecell)
        
        let subwebcamcell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let subwebcamswitch = newTableCellSwitch(subwebcamcell, label: NSLocalizedString("WebCam", comment: "preferences"), initial: (subs & SUBSCRIBE_VIDEOCAPTURE.rawValue) != 0)
        subwebcamcell.detailTextLabel!.text = NSLocalizedString("Receive webcam streams by default", comment: "preferences")
        subwebcamswitch.tag = Int(SUBSCRIBE_VIDEOCAPTURE.rawValue)
        subwebcamswitch.addTarget(self, action: #selector(PreferencesViewController.subscriptionChanged(_:)), forControlEvents: .ValueChanged)
        subscription_items.append(subwebcamcell)
        
        let submediafilecell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let submediafileswitch = newTableCellSwitch(submediafilecell, label: NSLocalizedString("Media File", comment: "preferences"), initial: (subs & SUBSCRIBE_MEDIAFILE.rawValue) != 0)
        submediafilecell.detailTextLabel?.text = NSLocalizedString("Receive media file streams by default", comment: "preferences")
        submediafileswitch.tag = Int(SUBSCRIBE_MEDIAFILE.rawValue)
        submediafileswitch.addTarget(self, action: #selector(PreferencesViewController.subscriptionChanged(_:)), forControlEvents: .ValueChanged)
        subscription_items.append(submediafilecell)
        
        let subdesktopcell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let subdesktopswitch = newTableCellSwitch(subdesktopcell, label: NSLocalizedString("Desktop", comment: "preferences"), initial: (subs & SUBSCRIBE_DESKTOP.rawValue) != 0)
        subdesktopcell.detailTextLabel!.text = NSLocalizedString("Receive desktop sessions by default", comment: "preferences")
        subdesktopswitch.tag = Int(SUBSCRIBE_DESKTOP.rawValue)
        subdesktopswitch.addTarget(self, action: #selector(PreferencesViewController.subscriptionChanged(_:)), forControlEvents: .ValueChanged)
        subscription_items.append(subdesktopcell)
        
        
        // text to speech events
        
        let ttsvoicecell = tableView.dequeueReusableCellWithIdentifier("Speech Cell")
        ttsvoicecell?.textLabel?.text = NSLocalizedString("Speech", comment: "preferences")
        ttsvoicecell?.detailTextLabel!.text = NSLocalizedString("Select the text-to-speech voice to use", comment: "preferences")
        ttsevents_items.append(ttsvoicecell!)

        ttsratecell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        var ttsrate = AVSpeechUtteranceDefaultSpeechRate
        if settings.valueForKey(PREF_TTSEVENT_RATE) != nil {
            ttsrate = settings.floatForKey(PREF_TTSEVENT_RATE)
        }
        let ttsrateslider = newTableCellSlider(ttsratecell!, label: NSLocalizedString("Speech Rate", comment: "preferences"),
            min: AVSpeechUtteranceMinimumSpeechRate, max: AVSpeechUtteranceMaximumSpeechRate, initial: Float(ttsrate))
        ttsrateslider.addTarget(self, action: #selector(PreferencesViewController.ttsrateChanged(_:)), forControlEvents: .ValueChanged)
        ttsrateChanged(ttsrateslider)
        ttsevents_items.append(ttsratecell!)
        
        ttsvolcell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        var ttsvol = DEFAULT_TTS_VOL
        if settings.valueForKey(PREF_TTSEVENT_VOL) != nil {
            ttsvol = settings.floatForKey(PREF_TTSEVENT_VOL)
        }
        let ttsvolslider = newTableCellSlider(ttsvolcell!, label: NSLocalizedString("Speech Volume", comment: "preferences"),
            min: 0, max: 1, initial: Float(ttsvol))
        ttsvolslider.addTarget(self, action: #selector(PreferencesViewController.ttsvolChanged(_:)), forControlEvents: .ValueChanged)
        ttsvolChanged(ttsvolslider)
        ttsevents_items.append(ttsvolcell!)


        let ttsjoinedchancell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let ttsjoinedchan = settings.objectForKey(PREF_TTSEVENT_JOINEDCHAN) == nil || settings.boolForKey(PREF_TTSEVENT_JOINEDCHAN)
        let ttsjoinedchanswitch = newTableCellSwitch(ttsjoinedchancell, label: NSLocalizedString("User joins channel", comment: "preferences"), initial: ttsjoinedchan)
        ttsjoinedchancell.detailTextLabel!.text = NSLocalizedString("Announce user joining channel", comment: "preferences")
        ttsjoinedchanswitch.addTarget(self, action: #selector(PreferencesViewController.ttsjoinedchanChanged(_:)), forControlEvents: .ValueChanged)
        ttsevents_items.append(ttsjoinedchancell)
        
        let ttsleftchancell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let ttsleftchan = settings.objectForKey(PREF_TTSEVENT_LEFTCHAN) == nil || settings.boolForKey(PREF_TTSEVENT_LEFTCHAN)
        let ttsleftchanswitch = newTableCellSwitch(ttsleftchancell, label: NSLocalizedString("User leaves channel", comment: "preferences"), initial: ttsleftchan)
        ttsleftchancell.detailTextLabel!.text = NSLocalizedString("Announce user leaving channel", comment: "preferences")
        ttsleftchanswitch.addTarget(self, action: #selector(PreferencesViewController.ttsleftchanChanged(_:)), forControlEvents: .ValueChanged)
        ttsevents_items.append(ttsleftchancell)

        let ttsconlostcell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let ttsconlost = settings.objectForKey(PREF_TTSEVENT_CONLOST) == nil || settings.boolForKey(PREF_TTSEVENT_CONLOST)
        let ttsconlostswitch = newTableCellSwitch(ttsconlostcell, label: NSLocalizedString("Connection lost", comment: "preferences"), initial: ttsconlost)
        ttsconlostcell.detailTextLabel!.text = NSLocalizedString("Announce lost server connection", comment: "preferences")
        ttsconlostswitch.addTarget(self, action: #selector(PreferencesViewController.ttsconlostChanged(_:)), forControlEvents: .ValueChanged)
        ttsevents_items.append(ttsconlostcell)
        
        let ttstxtmsgcell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let ttstxtmsg = settings.objectForKey(PREF_TTSEVENT_TEXTMSG) != nil && settings.boolForKey(PREF_TTSEVENT_TEXTMSG)
        let ttstxtmsgswitch = newTableCellSwitch(ttstxtmsgcell, label: NSLocalizedString("Private Text Message", comment: "preferences"), initial: ttstxtmsg)
        ttstxtmsgcell.detailTextLabel!.text = NSLocalizedString("Announce content of text message", comment: "preferences")
        ttstxtmsgswitch.addTarget(self, action: #selector(PreferencesViewController.ttsprivtxtmsgChanged(_:)), forControlEvents: .ValueChanged)
        ttsevents_items.append(ttstxtmsgcell)

        let ttschantxtmsgcell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let ttschantxtmsg = settings.objectForKey(PREF_TTSEVENT_CHANTEXTMSG) != nil && settings.boolForKey(PREF_TTSEVENT_CHANTEXTMSG)
        let ttschantxtmsgswitch = newTableCellSwitch(ttschantxtmsgcell, label: NSLocalizedString("Channel Text Message", comment: "preferences"), initial: ttschantxtmsg)
        ttschantxtmsgcell.detailTextLabel!.text = NSLocalizedString("Announce content of text message", comment: "preferences")
        ttschantxtmsgswitch.addTarget(self, action: #selector(PreferencesViewController.ttschantxtmsgChanged(_:)), forControlEvents: .ValueChanged)
        ttsevents_items.append(ttschantxtmsgcell)

        // version items
        
        let versioncell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        versioncell.textLabel?.text = NSLocalizedString("App Version", comment: "preferences")
        let v_str = String.fromCString(TT_GetVersion())!
        versioncell.detailTextLabel?.text = "\(AppInfo.getAppName()) v\(AppInfo.getAppVersion()), Library v\(v_str)"
        version_items.append(versioncell)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func soundeventChanged(sender: UISwitch) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        switch sender.tag {
        case Sounds.TX_ON.rawValue :
            defaults.setBool(sender.on, forKey: PREF_SNDEVENT_VOICETX)
        case Sounds.SRV_LOST.rawValue :
            defaults.setBool(sender.on, forKey: PREF_SNDEVENT_SERVERLOST)
        case Sounds.CHAN_MSG.rawValue :
            defaults.setBool(sender.on, forKey: PREF_SNDEVENT_CHANMSG)
        case Sounds.JOINED_CHAN.rawValue :
            defaults.setBool(sender.on, forKey: PREF_SNDEVENT_JOINEDCHAN)

        case Sounds.LEFT_CHAN.rawValue :
            defaults.setBool(sender.on, forKey: PREF_SNDEVENT_LEFTCHAN)
        case Sounds.USER_MSG.rawValue :
            defaults.setBool(sender.on, forKey: PREF_SNDEVENT_USERMSG)
        default :
            break
        }
    }
    
    func subscriptionChanged(sender: UISwitch) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        switch UInt32(sender.tag) {
        case SUBSCRIBE_USER_MSG.rawValue :
            defaults.setBool(sender.on, forKey: PREF_SUB_USERMSG)
        case SUBSCRIBE_CHANNEL_MSG.rawValue :
            defaults.setBool(sender.on, forKey: PREF_SUB_CHANMSG)
        case SUBSCRIBE_BROADCAST_MSG.rawValue :
            defaults.setBool(sender.on, forKey: PREF_SUB_BROADCAST)
        case SUBSCRIBE_VOICE.rawValue :
            defaults.setBool(sender.on, forKey: PREF_SUB_VOICE)
        case SUBSCRIBE_VIDEOCAPTURE.rawValue :
            defaults.setBool(sender.on, forKey: PREF_SUB_VIDEOCAP)
        case SUBSCRIBE_MEDIAFILE.rawValue :
            defaults.setBool(sender.on, forKey: PREF_SUB_MEDIAFILE)
        case SUBSCRIBE_DESKTOP.rawValue :
            defaults.setBool(sender.on, forKey: PREF_SUB_DESKTOP)
        default :
            break
        }
    }
    
    func nicknameChanged(sender: UITextField) {
        if ttInst != nil {
            TT_DoChangeNickname(ttInst, sender.text!)
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(sender.text!, forKey: PREF_NICKNAME)
    }
    
    func pttlockChanged(sender: UISwitch) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(sender.on, forKey: PREF_GENERAL_PTTLOCK)
    }
    
    func masterVolumeChanged(sender: UISlider) {
        let percent : Int = Int(sender.value * 10.0) * 10
        let vol = refVolume(Double(percent))
        if ttInst != nil {
            TT_SetSoundOutputVolume(ttInst, INT32(vol))
        }
        
        if UInt32(vol) == SOUND_VOLUME_DEFAULT.rawValue {
            let txt = String(format: NSLocalizedString("%d %% - Default", comment: "preferences"), percent)
            mastervolcell!.detailTextLabel!.text = txt
        }
        else {
            mastervolcell!.detailTextLabel!.text = "\(percent) %"
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(percent, forKey: PREF_MASTER_VOLUME)
    }
    
    func showtextmessagesChanged(sender: UISwitch) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(sender.on, forKey: PREF_DISPLAY_POPUPTXTMSG)
    }

    func ttsjoinedchanChanged(sender: UISwitch) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(sender.on, forKey: PREF_TTSEVENT_JOINEDCHAN)
    }

    func ttsleftchanChanged(sender: UISwitch) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(sender.on, forKey: PREF_TTSEVENT_LEFTCHAN)
    }

    func ttsconlostChanged(sender: UISwitch) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(sender.on, forKey: PREF_TTSEVENT_CONLOST)
    }
    
    func ttsprivtxtmsgChanged(sender: UISwitch) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(sender.on, forKey: PREF_TTSEVENT_TEXTMSG)
    }

    func ttschantxtmsgChanged(sender: UISwitch) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(sender.on, forKey: PREF_TTSEVENT_CHANTEXTMSG)
    }

    func proximityChanged(sender: UISwitch) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(sender.on, forKey: PREF_DISPLAY_PROXIMITY)
        
        let device = UIDevice.currentDevice()
        device.proximityMonitoringEnabled = sender.on
    }

    func limittextChanged(sender: UIStepper) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(Int(sender.value), forKey: PREF_DISPLAY_LIMITTEXT)
        let txt = String(format: NSLocalizedString("Limit length of names in channel list to %d characters", comment: "preferences"), Int(sender.value))
        limittextcell!.detailTextLabel!.text = txt
    }
    
    func showpublicserversChanged(sender: UISwitch) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(sender.on, forKey: PREF_DISPLAY_PUBSERVERS)
    }

    func showusernameChanged(sender: UISwitch) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(sender.on, forKey: PREF_DISPLAY_SHOWUSERNAME)
    }
    
    func speakeroutputChanged(sender: UISwitch) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(sender.on, forKey: PREF_SPEAKER_OUTPUT)
        
        enableSpeakerOutput(sender.on)
    }

    func headsetTxToggleChanged(sender: UISwitch) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(sender.on, forKey: PREF_HEADSET_TXTOGGLE)
        
        if sender.on {
            UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        }
        else {
            UIApplication.sharedApplication().endReceivingRemoteControlEvents()
        }
    }

    func voicepreprocessingChanged(sender: UISwitch) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(sender.on, forKey: PREF_VOICEPROCESSINGIO)
        
        TT_CloseSoundInputDevice(ttInst)
        TT_CloseSoundOutputDevice(ttInst)
        setupSoundDevices()
    }

    func voiceactlevelChanged(sender: UISlider) {
        let level = Int(sender.value * Float(VOICEACT_DISABLED))
        
        if level == VOICEACT_DISABLED {
            if ttInst != nil {
                TT_EnableVoiceActivation(ttInst, FALSE)
            }
            voiceactcell?.detailTextLabel?.text = NSLocalizedString("Voice Activation Level: Disabled", comment: "preferences")
        }
        else {
            if ttInst != nil {
                TT_EnableVoiceActivation(ttInst, TRUE)
                TT_SetVoiceActivationLevel(ttInst, INT32(level))
            }
            let txt = String(format: NSLocalizedString("Voice Activation Level: %d. Recommended: %d", comment: "preferences"), level, DEFAULT_VOICEACT)
            voiceactcell?.detailTextLabel?.text = txt
        }
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(level, forKey: PREF_VOICEACTIVATION)
    }
    
    func microphoneGainChanged(sender: UISlider) {
        let vol_pct : Int = Int(sender.value * 10.0) * 10
        let vol = refVolume(Double(vol_pct))
        if ttInst != nil {
            TT_SetSoundInputGainLevel(ttInst, INT32(vol))
        }
        
        if UInt32(vol) == SOUND_VOLUME_DEFAULT.rawValue {
            let txt = String(format: NSLocalizedString("%d %% - Default", comment: "preferences"), vol_pct)
            microphonecell!.detailTextLabel!.text = txt
        }
        else {
            microphonecell!.detailTextLabel!.text = "\(vol_pct) %"
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(vol_pct, forKey: PREF_MICROPHONE_GAIN)
    }

    func mediafileVolumeChanged(sender: UISlider) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setFloat(sender.value, forKey: PREF_MEDIAFILE_VOLUME)
        
        let vol = refVolume(100.0 * Double(sender.value))
        for u in users {
            TT_SetUserVolume(ttInst, u, STREAMTYPE_MEDIAFILE_AUDIO, INT32(vol))
        }
        
    }
    
    func ttsrateChanged(sender: UISlider) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setFloat(Float(sender.value), forKey: PREF_TTSEVENT_RATE)
        let txt = String(format: NSLocalizedString("The rate of the speaking voice is %.1f", comment: "preferences"), Float(sender.value))
        ttsratecell!.detailTextLabel!.text = txt
    }
    
    func ttsvolChanged(sender: UISlider) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setFloat(Float(sender.value), forKey: PREF_TTSEVENT_VOL)
        let txt = String(format: NSLocalizedString("The volume of the speaking voice is %.1f", comment: "preferences"), Float(sender.value))
        ttsvolcell!.detailTextLabel!.text = txt
    }
    
    func joinrootChanged(sender: UISwitch) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(sender.on, forKey: PREF_JOINROOTCHANNEL)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Select Voice" {
        }
    }

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return SECTIONS_COUNT
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case SECTION_GENERAL :
            return NSLocalizedString("General", comment: "preferences")
        case SECTION_DISPLAY :
            return NSLocalizedString("Display", comment: "preferences")
        case SECTION_SOUNDEVENTS :
            return NSLocalizedString("Sound Events", comment: "preferences")
        case SECTION_SOUND :
            return NSLocalizedString("Sound System", comment: "preferences")
        case SECTION_CONNECTION :
            return NSLocalizedString("Connection", comment: "preferences")
        case SECTION_SUBSCRIPTIONS :
            return NSLocalizedString("Default Subscriptions", comment: "preferences")
        case SECTION_TTSEVENTS :
            return NSLocalizedString("Text To Speech Events", comment: "preferences")
        case SECTION_VERSION :
            return NSLocalizedString("Version Information", comment: "preferences")
        default :
            return nil
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SECTION_GENERAL :
            return general_items.count
        case SECTION_DISPLAY :
            return display_items.count
        case SECTION_SOUNDEVENTS :
            return soundevents_items.count
        case SECTION_SOUND :
            return sound_items.count
        case SECTION_CONNECTION :
            return connection_items.count
        case SECTION_SUBSCRIPTIONS :
            return subscription_items.count
        case SECTION_TTSEVENTS :
            return ttsevents_items.count
        case SECTION_VERSION :
            return version_items.count
        default :
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case SECTION_GENERAL :
            return general_items[indexPath.row]
        case SECTION_DISPLAY :
            return display_items[indexPath.row]
        case SECTION_SOUNDEVENTS:
            return soundevents_items[indexPath.row]
        case SECTION_SOUND :
            return sound_items[indexPath.row]
        case SECTION_CONNECTION :
            return connection_items[indexPath.row]
        case SECTION_SUBSCRIPTIONS :
            return subscription_items[indexPath.row]
        case SECTION_TTSEVENTS:
            return ttsevents_items[indexPath.row]
        case SECTION_VERSION :
            return version_items[indexPath.row]
        default :
            return UITableViewCell()
        }
    }
    
    func handleTTMessage(var m: TTMessage) {
        
        switch m.nClientEvent {
            
        case CLIENTEVENT_CMD_USER_JOINED :
            let user = getUser(&m).memory
            users.insert(user.nUserID)
        case CLIENTEVENT_CMD_USER_LEFT :
            let user = getUser(&m).memory
            users.remove(user.nUserID)
        default : break
        }
    }
}
