//
//  StatsTabVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 21/06/24.
//

import UIKit

class StatsTabVC: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func statsDetailBtnActn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PatientStatsVC") as! PatientStatsVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
