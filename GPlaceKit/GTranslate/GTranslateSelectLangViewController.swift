//
//  GTranslateSelectLangViewController.swift
//  main
//
//  Created by jeanclad on 2017. 5. 16..
//  Copyright © 2017년 interpark-int. All rights reserved.
//

import Foundation

protocol GTranslateSelectLangViewControllerDelegate {
    func GTranslateSelectLangViewControllerDelegate(myType: GTranslateConstants.SelectLangType, model: GData)
}

class GTranslateSelectLangViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var delegate: GTranslateSelectLangViewControllerDelegate?
    private let suppertedLangArr = ManagerTranslate.sharedInstance.getCodeModel()?.gData
    
    public var myType: GTranslateConstants.SelectLangType?
    public var currentLangModel: GData?
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if myType! == GTranslateConstants.SelectLangType.outputLang {
            titleLabel.text = GTranslateConstants.Text().getTextSelectedLangTitle(type: myType!)
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        delegate!.GTranslateSelectLangViewControllerDelegate(myType: myType!, model: currentLangModel!)
        
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suppertedLangArr!.count - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "langCell", for: indexPath) as! LangTableViewCell
        cell.langNameLabel?.text = suppertedLangArr?[indexPath.row + 1].codeName
        
        if currentLangModel?.codeName == cell.langNameLabel?.text {
            cell.checkImageView.isHidden = false
            cell.langNameLabel.textColor = ManagerColor().colorFromRGB(0xe15684)
        } else {
            cell.checkImageView.isHidden = true
            cell.langNameLabel.textColor = ManagerColor().colorFromRGB(0x434e59)
        }
        
        return cell
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIndex = indexPath.row
        
        currentLangModel = suppertedLangArr?[selectedIndex + 1]
        
        tableView.reloadData()
        
        if myType == GTranslateConstants.SelectLangType.outputLang {
            ManagerTranslate.sharedInstance.setDstLangCode(code: (currentLangModel?.code)!)
        } else {
            ManagerTranslate.sharedInstance.setSrcLangCode(code: (currentLangModel?.code)!)
        }
        
        dismiss(animated: true, completion: nil)
        
        delegate!.GTranslateSelectLangViewControllerDelegate(myType: myType!, model: currentLangModel!)
    }
}

class LangTableViewCell: UITableViewCell {
    
    @IBOutlet var langNameLabel: UILabel!
    @IBOutlet var checkImageView: UIImageView!
}
