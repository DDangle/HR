//
//  DepartmentDAO.swift
//  Chapter06-HR
//
//  Created by 한규철 on 4/16/R4.
//

import UIKit

class DepartmentDAO {
    //부서 정보를 담을 튜플 타입 정의
    typealias DepartRecord = (Int, String, String)
    
    //SQLite 연결 및 초기화
    lazy var fmdb : FMDatabase! = {
        //파일 매니저 객체를 생성
        let fileMgr = FileManager.default
        
        //샌드박스 내 문서 디렉토리 에서 데이터베이스 파일 경로를 확인
        let docPath = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first
        
        let dbPath = docPath!.appendingPathComponent("hr.sqlite").path
        
        //샌드박스 경로에 파일이 없다면 메인 번들에 만들어 둔 hr.sqlite를 가져와 복사
        if fileMgr.fileExists(atPath: dbPath) == false {
            let dbSource = Bundle.main.path(forResource: "hr", ofType: "sqlite")
            try! fileMgr.copyItem(atPath: dbSource!, toPath: dbPath)
        }
        
        //준비된 데이터베이스 파일을 바탕으로 FMDatabase 객체를 생성
        let db = FMDatabase(path: dbPath)
        return db
    }()
    
    init() {
        self.fmdb.open()
    }
    
    deinit {
        self.fmdb.close()
    }
    
    //department 테이블로 부터 부서목록을 읽어올 메소드 find
    func find() -> [DepartRecord] {
        //반환할 데이터를 담을 [DepartRecord] 타입의 객체 정의
        var departList = [DepartRecord]()
        
        do {
            //부서 정보 목록을 가져올 SQL 작성 및 쿼리 실행
            let sql = """
            SELECT depart_cd, depart_title, depart_addr
            FROM department ORDER BY depart_cd ASC
            """
            
            let rs = try self.fmdb.executeQuery(sql, values: nil)
            
            //결과 집합 추출
            while rs.next() {
                let departCd = rs.int(forColumn: "depart_cd")
                let departTitle = rs.string(forColumn: "depart_title")
                let departAddr = rs.string(forColumn: "depart_addr")
                
                //append 메소드 호출 시 아래 튜플을 괄호 없이 사용하지 않도록 주의
                departList.append(( Int(departCd), departTitle!, departAddr! ))
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        return departList
    }
    
    //단일 부서 정보를 읽어올 메소드
    func get(departCd: Int) -> DepartRecord? {
        //질의 실행
        let sql = """
        SELECT depart_cd, depart_title, depart_addr
        FROM department
        WHERE depart_cd = ?
        """
        
        let rs = self.fmdb.executeQuery(sql, withArgumentsIn: [departCd])
        
        //결과 집합 처리
        if let _rs = rs {   //결과 집합이 옵셔널 타입으로 반환되므로, 이를 일반 상수에 바인딩하여 해제한다.
            _rs.next()
            
            let departId = _rs.int(forColumn: "depart_cd")
            let departTitle = _rs.string(forColumn: "depart_title")
            let departAddr = _rs.string(forColumn: "depart_addr")
            
            return (Int(departId), departTitle!, departAddr!)
            
        } else {    //결과 집합이 없을 경우 nil을 반환한다.
            return nil
        }
    }
    
    //부서 정보를 추가할 메소드 create(title:addr:)
    func create(title: String!, addr: String!) -> Bool {
        do {
            let sql = """
            INSERT INTO department (depart_title, depart_addr)
            VALUES (? , ?)
            """
            try self.fmdb.executeUpdate(sql, values: [title!, addr!])
            return true
        } catch let error as NSError {
            print("Insert Error : \(error.localizedDescription)")
            return false
        }
    }
    
    //부서 정보를 삭제할 메소드
    func remove(departCd: Int) -> Bool {
        do {
            let sql = "DELETE department WHERE depart_cd= ?"
            try self.fmdb.executeUpdate(sql, values: [departCd])
            return true
        } catch let error as NSError {
            print("DELETE Error: \(error.localizedDescription)")
            return false
        }
    }
    
   
}
