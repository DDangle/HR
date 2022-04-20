//
//  EmployeeListVC.swift
//  Chapter06-HR
//
//  Created by 한규철 on 4/16/R4.
//

import UIKit

class EmployeeListVC: UITableViewController {
    
    //데이터 소스를 저장할 멤버변수
    var empList: [EmployeeVO]!
    //SQLite 처리를 담당할 DAO 클래스
    var empDAO = EmployeeDAO()
    
    func initUI() {
        //내비게이션 타이틀용 레이블 속성 설정
        let navTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
        navTitle.numberOfLines = 2
        navTitle.textAlignment = .center
        navTitle.font = UIFont.systemFont(ofSize: 14)
        navTitle.text = "사원목록\n" + "총\(self.empList.count) 명"
        
        self.navigationItem.titleView = navTitle
    }
    
    //사원 등록 함수
    @IBAction func add(_ sender: Any) {
        
        let alert = UIAlertController(title: "사원 등록", message: "등록할 사원 정보를 입력해 주세요", preferredStyle: .alert)
        
        alert.addTextField() {(tf) in tf.placeholder = "사원명" }
        
        //contentViewController 영역에 부서 선택 피커 뷰 삽입
        let pickervc = DepartPickerVC()
        alert.setValue(pickervc, forKey: "contentViewController")
        
        //등록창 버튼 처리
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .default) { (_) in
            //사원 등록 처리 로직이 들어갈 영역
            //알림창의 입력 필드에서 값을 읽어온다.
            var param = EmployeeVO()
            param.departCd = pickervc.selectedDepartCd
            param.empName = (alert.textFields?[0].text)!
            
            //가입일은 오늘로 한다.
            let df = DateFormatter()
            df.dateFormat = "yyyy - MM - dd"
            param.joinDate = df.string(from: Date())
            
            //재직 상태는 '재직중' 으로 한다.
            param.stateCd = EmpStateType.ING
            
            //DB처리
            if self.empDAO.create(param: param) {
                //결과가 성공이면, 데이터를 다시 읽어들여 테이블 뷰를 갱신한다.
                self.empList = self.empDAO.find()
                self.tableView.reloadData()
                
                //내비게이션 타이틀을 갱신한다.
                if let navTitle = self.navigationItem.titleView as? UILabel {
                    navTitle.text = "사원목록 \n" + "총\(self.empList.count) 명"
                }
            }
        })
        self.present(alert, animated: false)
    }
    
    
    @IBAction func editing(_ sender: Any) {
        if self.isEditing == false { //현재의 편집 모드가 아닐때
            self.setEditing(true, animated: true)
            (sender as? UIBarButtonItem)?.title = "Done"
        } else { //현재의 편집 모드 일때
            self.setEditing(false, animated: true)
            (sender as? UIBarButtonItem)?.title = "Edit"
        }
    }
    
    override func viewDidLoad() {
        self.empList = self.empDAO.find()
        self.initUI()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.empList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let rowData = self.empList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "EMP_CELL")
        
        //사원명 + 재직 상태 출력
        cell?.textLabel?.text = rowData.empName + "(\(rowData.stateCd.desc()))"
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
        
        cell?.detailTextLabel?.text = rowData.departTitle
        cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
        
        return cell!
    }
    
    //목록 편집 형식을 결정하는 메소드 ( 삽입/ 삭제 )
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        return UITableViewCell.EditingStyle.delete
    }
    
    //목록 폅집 버튼을 클릭했을때 호출되는 메소드
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //삭제할 행의 empCd를 구한다.
        let empCd = self.empList[indexPath.row].empCd
        
        //DB에서, 데이터소스에서, 그리고 테이블 뷰에서 차례대로 삭제한다.
        if empDAO.remove(empCd: empCd) {
            self.empList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    
}
