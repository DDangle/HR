//
//  DepartmentListVC.swift
//  Chapter06-HR
//
//  Created by 한규철 on 4/16/R4.
//

import UIKit

class DepartmentListVC: UITableViewController {
    
    var departList: [(departCd: Int, departTitle: String, departAddr: String)]! //데이터 소스용 멤버변수
    
    let departDAO = DepartmentDAO() //SQLite 처리를 담당할 DAO객체
    
    func initUI() {
        
        //내비게이션 타이틀용 속성 설정
        let navTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
        navTitle.numberOfLines = 2
        navTitle.textAlignment = .center
        navTitle.font = UIFont.systemFont(ofSize: 14)
        navTitle.text = "부서 목록 \n" + "총 \(self.departList.count) 개"
        
        //내비게이션 바 UI설정
        self.navigationItem.titleView = navTitle
        self.navigationItem.leftBarButtonItem = self.editButtonItem //편집 버튼 추가
        
        //셀을 스와이프 했을 때, 편집모드가 되도록 설정
        self.tableView.allowsSelectionDuringEditing = true
    }
    
    override func viewDidLoad() {
        self.departList = self.departDAO.find() //기존 저장된 부서 정보를 가져온다.
        self.initUI()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.departList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //indexPath 매개변수가 가리키는 행에 대한 데이터를 읽어온다
        let rowData = self.departList[indexPath.row]
        
        //셀 객체를 생성하고 데이터를 배치한다.
        let cell = tableView.dequeueReusableCell(withIdentifier: "DEPART_CELL")
        
        cell?.textLabel?.text = rowData.departTitle
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
        
        cell?.detailTextLabel?.text = rowData.departAddr
        cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
        
        return cell!
        
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //삭제할 행의 departCd를 구한다.
        let departCd = self.departList[indexPath.row].departCd
        
        //DB 에서, 데이터소스에서, 그리고 테이블 뷰에서 차례대로 삭제한다.
        if departDAO.remove(departCd: departCd) {
            self.departList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //화면 이동시 함께 전달할 부서 코드
        let departCd = self.departList[indexPath.row].departCd
        
        //이동할 대상 뷰 컨트롤러의 인스턴스
        let infoVC = self.storyboard?.instantiateViewController(withIdentifier: "DEPART_INFO")
        
        if let _infoVC = infoVC as? DepartmentInfoVC {
            //부서 코드를 전달한 다음, 푸시 방식으로 화면으로 이동
            _infoVC.departCd = departCd
            self.navigationController?.pushViewController(_infoVC, animated: true)
        }
    }
    
    //신규 부서를 추가하는 메소드
    @IBAction func add(_ sender: Any) {
        //여기에 비즈니스 로직이 들어갑니다.
        let alert = UIAlertController(title: "신규 부서 등록", message: "신규 부서를 등록해 주세요", preferredStyle: .alert)
        
        //부서명 및 주소 입력용 텍스트 필드 추가
        alert.addTextField() { (tf) in tf.placeholder = "부서명"}
        alert.addTextField() { (tf) in tf.placeholder = "주소"}
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .default) { (_) in
            
            //부서 등록 로직이 들어갈 자리입니다.
            
            let title = alert.textFields?[0].text //부서명
            let addr = alert.textFields?[1].text //부서주소
            print("title : \(title), addr : \(addr)")
            if self.departDAO.create(title: title!, addr: addr!) {
                //신규 부서가 등록되면 db에서 목록을 다시읽어온 후, 테이블을 갱신해 준다.
                self.departList = self.departDAO.find()
                self.tableView.reloadData()
                
                //내비게이션 타이틀에도 변경된 부서 정보를 반영해준다.
                let navtitle = self.navigationItem.titleView as! UILabel
                navtitle.text = "부서목록 + \n" + "총 \(self.departList.count) 개"
            }
            
        })
        self.present(alert, animated: false)
    }
}
