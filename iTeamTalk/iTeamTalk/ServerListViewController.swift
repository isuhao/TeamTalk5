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

// Properties of a TeamTalk server to connect to
class Server : NSObject {
    var name = ""
    var ipaddr = ""
    var tcpport = AppInfo.DEFAULT_TCPPORT
    var udpport = AppInfo.DEFAULT_UDPPORT
    var username = ""
    var password = ""
    var channel = ""
    var chanpasswd = ""
    var publicserver = false
    var encrypted = false
    
    override init() {
        
    }
    
    init(coder dec: NSCoder!) {
        name = dec.decodeObjectForKey("name") as! String
        ipaddr = dec.decodeObjectForKey("ipaddr") as! String
        tcpport = dec.decodeIntegerForKey("tcpport")
        udpport = dec.decodeIntegerForKey("udpport")
        username = dec.decodeObjectForKey("username") as! String
        password = dec.decodeObjectForKey("password") as! String
        channel = dec.decodeObjectForKey("channel") as! String
        chanpasswd = dec.decodeObjectForKey("chanpasswd") as! String
    }
    
    func encodeWithCoder(enc: NSCoder!) {
        enc.encodeObject(name, forKey: "name")
        enc.encodeObject(ipaddr, forKey: "ipaddr")
        enc.encodeInteger(tcpport, forKey: "tcpport")
        enc.encodeInteger(udpport, forKey: "udpport")
        enc.encodeObject(username, forKey: "username")
        enc.encodeObject(password, forKey: "password")
        enc.encodeObject(channel, forKey: "channel")
        enc.encodeObject(chanpasswd, forKey: "chanpasswd")
    }
}

class ServerListViewController : UITableViewController,
    NSXMLParserDelegate {
    
    // server for segue
    var currentServer = Server()
    // list of available servers
    var servers = [Server]()
    
    var nextappupdate = NSDate()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let addbtn = self.navigationItem.rightBarButtonItem {
            addbtn.accessibilityHint = NSLocalizedString("Add new server entry", comment: "serverlist")
        }
        if let setupbtn = self.navigationItem.leftBarButtonItem {
            setupbtn.accessibilityLabel = NSLocalizedString("Preferences", comment: "serverlist")
            setupbtn.accessibilityHint = NSLocalizedString("Access preferences", comment: "serverlist")
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        servers.removeAll()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let stored = defaults.arrayForKey("ServerList") {
            for e in stored {
                let data = e as! NSData
                
                let server = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Server
                
                servers.append(server)
            }
        }
        
        if defaults.objectForKey(PREF_DISPLAY_PUBSERVERS) == nil || defaults.boolForKey(PREF_DISPLAY_PUBSERVERS) {
            NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ServerListViewController.downloadServerList), userInfo: nil, repeats: false)
        }

        tableView.reloadData()
        
        if nextappupdate.earlierDate(NSDate()) == nextappupdate {
            NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(ServerListViewController.checkAppUpdate), userInfo: nil, repeats: false)
        }
        
    }
    
    func checkAppUpdate() {

        // check for new version
        let updateparser = AppUpdateParser()
        
        let parser = NSXMLParser(contentsOfURL: NSURL(string: AppInfo.getUpdateURL())!)!
        parser.delegate = updateparser
        parser.parse()
        
        nextappupdate = nextappupdate.dateByAddingTimeInterval(60 * 60 * 24)
    }
    
    func downloadServerList() {

        // get xml-list of public server
        let serverparser = ServerParser()
        
        let parser = NSXMLParser(contentsOfURL: NSURL(string: AppInfo.getServersURL())!)!
        parser.delegate = serverparser
        parser.parse()

        for s in serverparser.servers {
            servers.append(s)
        }
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveServerList() {
        //Store local servers
        let localservers = servers.filter({$0.publicserver == false})
        let defaults = NSUserDefaults.standardUserDefaults()
        var s_array = [NSData]()
        for s in localservers {
            let data = NSKeyedArchiver.archivedDataWithRootObject(s)
            s_array.append(data)
        }
        defaults.setObject(s_array, forKey: "ServerList")
        defaults.synchronize()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return servers.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "ServerTableCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ServerTableCell
        
        let server = servers[indexPath.row]
        cell.connectBtn.tag = indexPath.row
        cell.nameLabel.text = server.name
        cell.ipaddrLabel.text = server.ipaddr
        if server.publicserver {
            cell.iconImageView.image = UIImage(named: "teamtalk_green.png")
            cell.iconImageView.accessibilityLabel = NSLocalizedString("Public server", comment: "serverlist")
        }
        else {
            cell.iconImageView.image = UIImage(named: "teamtalk_yellow.png")
            cell.iconImageView.accessibilityLabel = NSLocalizedString("Private server", comment: "serverlist")
        }
        
        if #available(iOS 8.0, *) {
            let action_connect = MyCustomAction(name: NSLocalizedString("Connect to server", comment: "serverlist"), target: self, selector: #selector(ServerListViewController.connectServer(_:)), tag: indexPath.row)
            let action_delete = MyCustomAction(name: NSLocalizedString("Delete server from list", comment: "serverlist"), target: self, selector: #selector(ServerListViewController.deleteServer(_:)), tag: indexPath.row)
            cell.accessibilityCustomActions = [action_connect, action_delete]
        } else {
            // Fallback on earlier versions
        }
        
        return cell
    }

    @available(iOS 8.0, *)
    func connectServer(action: UIAccessibilityCustomAction) -> Bool {
        
        if let ac = action as? MyCustomAction {
            currentServer = servers[ac.tag]
            performSegueWithIdentifier("Show ChannelList", sender: self)
        }
        return true
    }
    
    @available(iOS 8.0, *)
    func deleteServer(action: UIAccessibilityCustomAction) -> Bool {
        
        if let ac = action as? MyCustomAction {
            servers.removeAtIndex(ac.tag)
            saveServerList()
            tableView.reloadData()
        }
        return true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Show Server" {
            let index = self.tableView.indexPathForSelectedRow
            currentServer = servers[index!.row]
            let serverDetail = segue.destinationViewController as! ServerDetailViewController
            serverDetail.server = currentServer
        }
        else if segue.identifier == "New Server" {
            
        }
        else if segue.identifier == "Show ChannelList" {
            let vc = segue.destinationViewController as! MainTabBarController
            vc.setTeamTalkServer(currentServer)
        }
    }
    
    @IBAction func deleteServerDetail(segue:UIStoryboardSegue) {
        let vc = segue.sourceViewController as! ServerDetailViewController
        
        vc.saveServerDetail()
        let name = vc.namefield?.text
        
        servers = servers.filter({$0.name != name})
        
        saveServerList()
        
        tableView.reloadData()
    }
    
    @IBAction func saveServerDetail(segue:UIStoryboardSegue) {
        let vc = segue.sourceViewController as! ServerDetailViewController
        
        vc.saveServerDetail()
        let name = vc.server.name
        
        if let found = servers.map({$0.name}).indexOf(name) {
            servers[found] = vc.server
        }
        else {
            servers.append(vc.server)
        }
        
        self.currentServer = vc.server
        
        saveServerList()
        
        tableView.reloadData()
    }
    
    @IBAction func connectToServer(sender: UIButton) {
        currentServer = servers[sender.tag]
    }

    func openUrl(url: NSURL) {
        
        if url.fileURL {
            // get server from either .tt file or tt-URL
            let serverparser = ServerParser()
            
            let parser = NSXMLParser(contentsOfURL: url)!
            parser.delegate = serverparser
            parser.parse()
            
            for s in serverparser.servers {
                currentServer = s
            }
        }
        else {
            do {
                // assume TT url
                let url_str = url.absoluteString
                let ns_str = url_str as NSString
                let url_range = NSMakeRange(0, url_str.characters.count)

                // ip-addr
                let host = AppInfo.TTLINK_PREFIX + "([^\\??!/]*)/?\\??"
                let host_regex = try NSRegularExpression(pattern: host, options: .CaseInsensitive)
                let host_matches = host_regex.matchesInString(url_str, options: .ReportCompletion, range: url_range)
                if let m = host_matches.first {
                    currentServer.ipaddr = ns_str.substringWithRange(m.rangeAtIndex(1))
                }
                
                //tcp port
                let tcpport = "[&|\\?]tcpport=(\\d+)"
                let tcpport_regex = try NSRegularExpression(pattern: tcpport, options: .CaseInsensitive)
                let tcpport_matches = tcpport_regex.matchesInString(url_str, options: .ReportCompletion, range: url_range)
                if let m = tcpport_matches.first {
                    let s = ns_str.substringWithRange(m.rangeAtIndex(1))
                    currentServer.tcpport = Int(s)!
                }
                
                // udp port
                let udpport = "[&|\\?]udpport=(\\d+)"
                let udpport_regex = try NSRegularExpression(pattern: udpport, options: .CaseInsensitive)
                let udpport_matches = udpport_regex.matchesInString(url_str, options: .ReportCompletion, range: url_range)
                if let m = udpport_matches.first {
                    let s = ns_str.substringWithRange(m.rangeAtIndex(1))
                    currentServer.udpport = Int(s)!
                }

                // username
                let username = "[&|\\?]username=([^&]*)"
                let username_regex = try NSRegularExpression(pattern: username, options: .CaseInsensitive)
                let username_matches = username_regex.matchesInString(url_str, options: .ReportCompletion, range: url_range)
                if let m = username_matches.first {
                    currentServer.username = ns_str.substringWithRange(m.rangeAtIndex(1))
                }
                
                // password
                let password = "[&|\\?]password=([^&]*)"
                let password_regex = try NSRegularExpression(pattern: password, options: .CaseInsensitive)
                let password_matches = password_regex.matchesInString(url_str, options: .ReportCompletion, range: url_range)
                if let m = password_matches.first {
                    currentServer.password = ns_str.substringWithRange(m.rangeAtIndex(1))
                }
                
                // channel
                let channel = "[&|\\?]channel=([^&]*)"
                let channel_regex = try NSRegularExpression(pattern: channel, options: .CaseInsensitive)
                let channel_matches = channel_regex.matchesInString(url_str, options: .ReportCompletion, range: url_range)
                if let m = channel_matches.first {
                    currentServer.channel = ns_str.substringWithRange(m.rangeAtIndex(1))
                }
                
                // channel password
                let chpasswd = "[&|\\?]chanpasswd=([^&]*)"
                let chpasswd_regex = try NSRegularExpression(pattern: chpasswd, options: .CaseInsensitive)
                let chpasswd_matches = chpasswd_regex.matchesInString(url_str, options: .ReportCompletion, range: url_range)
                if let m = chpasswd_matches.first {
                    currentServer.chanpasswd = ns_str.substringWithRange(m.rangeAtIndex(1))
                }
            }
            catch {
                
            }
        }
        
        if !currentServer.ipaddr.isEmpty {
            performSegueWithIdentifier("Show ChannelList", sender: self)
        }
    }
}

class AppUpdateParser : NSObject, NSXMLParserDelegate {

    var update = ""
    var updatefound = false
    
    func parser(parser: NSXMLParser, didStartElement elementName: String,
        namespaceURI: String?, qualifiedName qName: String?,
        attributes attributeDict: [String : String]) {
            
            if elementName == "name" {
                updatefound = true
            }
    }

    func parser(parser: NSXMLParser, foundCharacters string: String) {
        update = string
    }

    func parser(parser: NSXMLParser, didEndElement elementName: String,
        namespaceURI: String?, qualifiedName qName: String?) {
            
    }

}

class ServerParser : NSObject, NSXMLParserDelegate {
    
    var currentServer = Server()
    var elementStack = [String]()
    var servers = [Server]()
    
    func parser(parser: NSXMLParser, didStartElement elementName: String,
        namespaceURI: String?, qualifiedName qName: String?,
        attributes attributeDict: [String : String]) {
            
            elementStack.append(elementName)
            if elementName == "host" {
                currentServer = Server()
            }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
        switch elementStack.last! {
        case "teamtalk" : break
        case "host" : break
            
        case "name" :
            currentServer.name = string
        case "address" :
            currentServer.ipaddr = string
        case "tcpport" :
            let v : String = string
            currentServer.tcpport = Int(v)!
        case "udpport" :
            let v : String = string
            currentServer.udpport = Int(v)!
        case "encrypted" :
            currentServer.encrypted = string == "true"
            
        case "auth" : break
        case "join" : break
            
        case "username" :
            currentServer.username = string
        case "password" :
            if elementStack.indexOf("auth") != nil {
                currentServer.password = string
            }
            else if elementStack.indexOf("join") != nil {
                currentServer.chanpasswd = string
            }
        case "channel" :
            currentServer.channel = string
        default :
            print("Unknown tag " + self.elementStack.last!)
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String,
        namespaceURI: String?, qualifiedName qName: String?) {
            
            self.elementStack.removeLast()
            if elementName == "host" {
                currentServer.publicserver = true
                servers.append(currentServer)
            }
    }
    
}
