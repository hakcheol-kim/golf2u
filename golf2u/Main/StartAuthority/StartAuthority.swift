
import UIKit

protocol StartAuthorityPopDelegate: class {
    func finishStartAuthority()
}

class StartAuthority: VariousViewController {
    
    weak var m_tfinishStartAuthority: StartAuthorityPopDelegate?
    
    @IBOutlet weak var uiLb1: UILabel!
    @IBOutlet weak var uiLb2: UILabel!
    @IBOutlet weak var uiLb3: UILabel!
    @IBOutlet weak var uiLb4: UILabel!
    @IBOutlet weak var uiLb5: UILabel!
    @IBOutlet weak var uiLb6: UILabel!
    @IBOutlet weak var uiLb7: UILabel!
    @IBOutlet weak var uiLb8: UILabel!
    @IBOutlet weak var uiAccBtn: UIButton!
    
    static func instantiate() -> StartAuthority? {
        return UIStoryboard(name: "StartAuthority", bundle: nil).instantiateViewController(withIdentifier: "\(StartAuthority.self)") as? StartAuthority
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiLb1.text = "앱 접근권한 안내".localized;
        uiLb2.text = "랜덤투유에서는 다음 권한들이 필요합니다.\n서비스 이용을 위해 동의해주세요.".localized;
        uiLb3.text = "기기 및 앱 기록(필수)".localized;
        uiLb4.text = "앱 사용성 개선 및 오류 모니터링".localized;
        uiLb5.text = "알림(선택)".localized;
        uiLb6.text = "트레이드,시스템알림,이벤트 광고 알림\n등의 접근 필요".localized;
        uiLb7.text = "갤러리(선택)".localized;
        uiLb8.text = "이미지 등록을 위한 접근 필요".localized;
        uiAccBtn.setTitle("확인".localized, for: .normal)
        self.uiAccBtn.layer.addBorder([.top], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
       
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.m_tfinishStartAuthority?.finishStartAuthority();
       
    }
    @IBAction func onCloseBtn(_ sender: Any) {
        //self.m_tfinishStartAuthority?.finishStartAuthority();
        dismiss(animated: true, completion: nil)
    }
    
    
}
