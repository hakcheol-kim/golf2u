//
//  JsonC.swift
//  H2Care
//
//  Created by lee wonyoung on 2019/10/24.
//  Copyright © 2019 Lee.210. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class JsonC{
    private var SO:Single = Single.getSO();
    private let DI = DeviceInfo();
    
    
    private var request: DataRequest? { didSet { oldValue?.cancel() } }
    
    private var OriPram:[String : Any] = [:];
    private var OriPramS:[String : String] = [:];
    
    struct CustomGetEncoding : ParameterEncoding {
        func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
            var request = try URLEncoding().encode(urlRequest, with: parameters)
            request.url = URL(string: request.url!.absoluteString.replacingOccurrences(of: "%5B%5D=", with: "="))
            return request
        }
    }
    func ParamMerge(param : [String : Any]) -> [String : Any]{
        var fmOriParam = OriPram;
        
        fmOriParam["device_id"] = String(describing: SO.deviceUUID!)
        fmOriParam["os_type"] = Single.DE_PLATFORMIDX
        fmOriParam["model_name"] = DI.iPhoneModel();
        fmOriParam["os_version"] = "\(String(describing: SO.versionbuild!))";
        
        for (key, value) in param {
            fmOriParam[key] = value;
        }
        return fmOriParam;
    }
    func ParamMerge(param : [String : String]) -> [String : String]{
        var fmOriParam = OriPramS;
        
        fmOriParam["device_id"] = String(describing: SO.deviceUUID!)
        fmOriParam["os_type"] = Single.DE_PLATFORMIDX
        fmOriParam["model_name"] = DI.iPhoneModel();
        fmOriParam["os_version"] = "\(String(describing: SO.versionbuild!))";
        
        for (key, value) in param {
            fmOriParam[key] = value;
        }
        return fmOriParam;
    }
    func JSONSend(url : String, param : [String : Any], callbackf : @escaping  (JSON)->Void){
        self.request = AF.request(url,method: .post, parameters: param, encoding: CustomGetEncoding())
        self.request?.responseJSON{ (response) in
            switch response.result {
            case .success(let value):
                callbackf(JSON(value))
                break
            //case .failure(_):
            case .failure(let error):
                print("Function: \(#function), line: \(#line)")
                print(error);
                break
                
            }
        }
    }
    func JSONSend(url : String, param : [String : String], Imgs : [String : UIImage] , callbackf : @escaping  (JSON)->Void){
        //let image = UIImage(named: "Image")
        //let imgData = image!.jpegData(compressionQuality: 0.2)!
        
        AF.upload(multipartFormData: { multipartFormData in
            for (key , val) in param{
                multipartFormData.append(Data(val.utf8), withName: key)
            }
            for (key, img) in Imgs{
                let imgData = img.jpegData(compressionQuality: 0.2)!
                //multipartFormData.append(imgData, withName: key)
                multipartFormData.append(imgData, withName: key,fileName: "a.jpg", mimeType: "image/jpg")
            }
            //multipartFormData.append(imgData, withName: "Name")
            //multipartFormData.append(Data("value".utf8), withName: "")
            //multipartFormData.append(imgData, withName: "key",fileName: "a.jpg", mimeType: "image/jpg")

        }, to: url)
        .responseJSON { response in
            switch response.result {
            case .success(let value):
                callbackf(JSON(value))
                break
            //case .failure(_):
            case .failure(let error):
                print("Function: \(#function), line: \(#line)")
                print(error);
                break
                
            }
        }
    }
    
    //MARK: API START
    
    
    func CategoryListGet(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        
        let fm_OriParam = ParamMerge(param : param);
        
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/product/getAllCategory";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
        
    }
    
    
    //로그인
    func Login(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        
        let fm_OriParam = ParamMerge(param : param);
        
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/user/login";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //닉네임 중복체크
    func NickNameCheck(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        
        let fm_OriParam = ParamMerge(param : param);
        
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/user/chkDupName";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //이메일 중복체크
    func EmailCheck(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        
        let fm_OriParam = ParamMerge(param : param);
        
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/user/chkDupEmail";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //회원가입
    func MemberJoin(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        
        let fm_OriParam = ParamMerge(param : param);
        
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/user/join";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //이메일 전송 신청 및 코드값 받기
    func EmailSendPlzRtsCode(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        
        let fm_OriParam = ParamMerge(param : param);
        
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/user/sendAuthEmail";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //비번 찾기 중 이메일 또는 닉네임 검색
    func PassFindEmailORNick(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        
        let fm_OriParam = ParamMerge(param : param);
        
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/user/checPwEmail";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //비번찾기중 이메일 전송 및 비번 초기화
    func PassFindPassInit(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        
        let fm_OriParam = ParamMerge(param : param);
        
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/user/sendPwEmail";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //SNS 로그인
    func SNSLogin(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        
        let fm_OriParam = ParamMerge(param : param);
        
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/user/loginSns";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //자동 로그인
    func AutoLogin(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        
        let fm_OriParam = ParamMerge(param : param);
        
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/user/loginSeq";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //메인 상품 리스트
    func getMainProductList(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        
        let fm_OriParam = ParamMerge(param : param);
        
        /*
         pagenum: 페이지번호 (디폴트 1)
         category_seqs : 선택한 카테고리 seq 목록 (array)
         password : 비밀번호
         order_type : 정렬순서 (0:가격순, 1:등록순, 디폴트 0)
         */
        
        //let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/product/getAllProduct";
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/v2/product/getAllProduct";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //메인 배너
    func getMainBanner(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        
        let fm_OriParam = ParamMerge(param : param);
        
        /*
         type:배너 타입(0:메인 상단 배너, 1:메인 하단 띠배너, 없을 경우 전체)
         */
        
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Banner/getAllBanner";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //상품상세정보
    func getProductDetail(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/product/getProduct";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //상품 상세 정보 좋아요 토글
    func ProductCommentLikeToggle(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/product/togleLikeComment";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //상품후기조회
    func ProductCommentDetail(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/product/getAllComment";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //상품후기 등록
    func ProductCommentInsert(param : [String : String], imgs : [String : UIImage], callbackf : @escaping  (JSON)->Void){
        
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/product/setComment";
        self.JSONSend(url: url, param: fm_OriParam,Imgs: imgs , callbackf: callbackf)
    }
    //상품후기 삭제
    func ProductCommentDelete(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/product/delComment";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //트레이트 상품목록 조회
    func TradeProductList(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Trade/getAllTradeProduct";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //트레이트 회원 조회
    func TradeMemberList(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Trade/getAllTradeUser";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //상품등록고객
    func TradeProductMemberList(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Trade/getAllTradeProductUser";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //트레이드 신청
    func TradeApply(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Trade/getAllUserProducts";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //트레이드 신청 확인 신청
    func TradeApplyTry(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Trade/requestTrade";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //트레이트 현황
    func TradeStatusList(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Trade/getAllUserTrade";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //트레이트 현황 삭제
    func TradeStatusListDelete(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Trade/invisibleTrade";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //트레이드 현황에서 클릭시 확인창에 상대방 정보 가져오기
    func TradeUserInfoGet(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Trade/getUserTrade";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //트레이드 현황에서 클릭시 확인창에 상품목록 가져오기
    func TradeTryProductsGet(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Trade/getAllTradeProducts";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //트레이드 현황에서 클릭시 확인창에서 2거절,3취소,5수락 버튼 기능
    func TradeTryCtrl(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Trade/ctrlTrade";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //블랙 리스트 또는 친구 추가 삭제 토글
    func FriendORBlackListToggle(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/relation/toggleRelation";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //트레이드 현황에서 상세페이지에서 흥정하기를 클릭할경우 기존에 상대방의 선택한 상품 목록 seq 가져오기
    func TradeDealTopUserProductsGet(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Trade/getAllTradeProductsForRetry";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //트레이드 현황에서 상세페이지에서 흥정하기를 클릭할경우 기존에 상대방의 선택한 상품 목록 seq 가져오기
    func TradeDealTopUserProductsGetV2(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/v2/Trade/getAllTradeProductsForRetry";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //커뮤니티 뉴스룸 배너 가져오기
    func CommunityBannerNewsRoom(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Newsroom/getNewsroomBanner";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //커뮤니티 뉴스룸 리스트 가져오기
    func CommunityListNewsRoom(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Newsroom/getAllNewsroom";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //커뮤니티 댓글
    func CommunityCommentListNewsRoom(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Newsroom/getAllComment";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //커뮤니티 댓글 좋아요 토글
    func CommunityCommentLikeToggleNewsRoom(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Newsroom/togleLikeComment";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //커뮤니티 뉴스룸 코멘트 등록
    func NewsRoomCommentInsert(param : [String : String], imgs : [String : UIImage], callbackf : @escaping  (JSON)->Void){
        
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Newsroom/setComment";
        self.JSONSend(url: url, param: fm_OriParam,Imgs: imgs , callbackf: callbackf)
    }
    //뉴스룸 댓글 삭제
    func NewsRoomCommentDelete(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Newsroom/delComment";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //위클리 배너
    func WeeklyBanner(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Weekly_ranking/getMyWeeklyRanking";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //위클리 리스트 가져오기
    func WeeklyMainList(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Weekly_ranking/getAllWeeklyRanking";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //위클리 서브리스트 가져오기
    func WeeklySubList(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Weekly_ranking/getAllPrevWeeklyRanking";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //인벤토리 박스 보관함리스트
    func InventoryBoxList(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Inventory/getAllMyBoxs";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //박스 획득 가능상품목록
    func InventoryBoxRandomList(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Inventory/getAllBoxProducts";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //은행 목록
    func BankList(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Inventory/getAllBankCodes";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //박스 결제 취소
    func BoxBuyCancel(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Inventory/cancelBox";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //박스 남은 개수
    func getMyBoxCnt(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Inventory/getAllMyBoxsCnt";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //박스 오픈
    func BoxOpen(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Inventory/openBoxs";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //커뮤니티 댓글 신고하기
    func ComunityCommentSiren(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Newsroom/insertCommentReport";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //친구 목록
    func FriendList(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Relation/getAllFriend";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //친구 삭제
    func FriendDelete(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Relation/deleteFriend";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //친구/블랙리스트 회원 검색
    func FriendABlackSearch(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Relation/searchRelationUsers";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //친구 추가
    func FriendAdd(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Relation/insertFriend";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //블랙리스트 목록조회
    func BlackList(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Relation/getAllBlack";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //블랙리스트 해제
    func BlackListDel(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Relation/deleteRelation";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //블랙리스트 추가Add
    func BlackListAdd(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Relation/insertBlack";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //내 선물가능한 박스 목록
    func MyBoxList(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Inventory/getAllMyBoxsCanGift";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //내 선물가능한 박스 목록
    func MyProductList(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Inventory/getAllMyProducts2";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //내 박스 상품 선물하기
    func MyBoxProGift(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Gift/insertGift";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //친구 신청 목록
    func FriendSendInfoList(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Relation/getAllRelationRequests";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //친구 신청 취소,수락,거절
    func FriendSendResult(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Relation/ctrlRelationRequest";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //인벤토리 상품 보관함 리스트
    func InvenProductList(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Inventory/getAllMyProducts";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //선물 코드 생성
    func GiftCodeCreate(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Inventory/makeGiftCode";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //상품 마켓 등록
    func ProductMarketAdd(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Trade/insertTradeProduct";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //클로버 환급
    func CloverReturn(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Inventory/refundMyProduct";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //상품 마켓 등록 취소
    func ProductMarketDel(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Trade/deleteTradeProduct";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //배송신청 기본정보 조회
    func DeliveryDefInfo(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Order/getUserDeliverySummary";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //배송상품 추가
    func getAllMyProductsCanOrder(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/inventory/getAllMyProductsCanOrder";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //배송지 목록 조회
    func getAllUserAddress(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Order/getAllUserAddress";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //배송지 목록 삭제
    func deleteUserAddress(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Order/deleteUserAddress";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //배송지 추가
    func InsertUserAddress(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Order/InsertUserAddress";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //배송지 수정
    func updateUserAddress(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Order/updateUserAddress";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //선물함 받은선물
    func getAllRecvGift(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Gift/getAllRecvGift";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //선물함 보낸선물
    func getAllSendGift(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Gift/getAllSendGift";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //선물함 보낸 받음 선물 삭제
    func deleteGift(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Gift/deleteGift";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //선물수령하기
    func takeGift(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Gift/takeGift";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //선쿨코드 입력
    func takeCodeGift(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Gift/takeCodeGift";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //디지털상품 배송신청
    func getMyProductGifticon(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Inventory/getMyProductGifticon";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //박스구매 초기 데이터
    func getUserPurchaseSummary(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Purchase/getUserPurchaseSummary";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //클로버 내역
    func getAllUserPointHistory(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Point/getAllUserPointHistory";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //배송 조회
    func getAllUserOrder(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Order/getAllUserOrder";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //배송 취소
    func cancelOrder(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Order/cancelOrder";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //배송 후기 작성 가능한 리스트
    func getOrderComplete(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Order/getOrderComplete";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //배송상세보기 팝업
    func getOrder(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Order/getOrder";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //쿠폰함
    func getAllRecvableCoupon(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Coupon/getAllRecvableCoupon";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //쿠폰 다운로드
    func takeCoupon(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Coupon/takeCoupon";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //쿠폰 등록
    func takeCodeCoupon(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Coupon/takeCodeCoupon";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //1:1문의 목록
    func getAllUserQna(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Cs/getAllUserQna";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //1:1문의 카테고리 목록
    func getAllQnaCategory(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Cs/getAllQnaCategory";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //1:1문의 등록
    func setQna(param : [String : String], imgs : [String : UIImage], callbackf : @escaping  (JSON)->Void){
        
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Cs/setQna";
        self.JSONSend(url: url, param: fm_OriParam,Imgs: imgs , callbackf: callbackf)
    }
    
    //1:1문의 상세보기 조회
    func getUserQna(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Cs/getUserQna";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //1:1문의 삭제
    func delQna(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Cs/delQna";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //공지사항
    func getAllNotice(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Cs/getAllNotice";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //이벤트 목록
    func getAllEvent(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Cs/getAllEvent";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //로그아웃
    func logout(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/User/logout";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //설정 기본정보 가져오기
    func getPushAgreeState(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/User/getPushAgreeState";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //설정 상품 보관함 토글
    func toggleTradeInv(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Setting/toggleTradeInv";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //설정 푸시 토글
    func togglePushState(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/User/togglePushState";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //고객센터 이벤트 상세페이지
    func getEvent(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Cs/getEvent";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //친구 코드 생성
    func setInvCode(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/User/setInvCode";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //친구 코드 입력
    func insertInvCode(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/User/insertInvCode";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //닉네임 변경
    func setName(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/user/setName";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //비밀번호 변경
    func setPassword(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/user/setPassword";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //탈퇴
    func UserLeave(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/User/UserLeave";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //sns 가입 여부
    func checkSns(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/user/checkSns";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //푸시 리스트
    func getAllUserNotification(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Notification/getAllUserNotification";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //푸시 삭제
    func invisibleNotification(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Notification/invisibleNotification";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //시스템정보
    func getAppInfo(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/setting/getAppInfo";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //프로필 이미지 변경
    func setProfile(param : [String : String], imgs : [String : UIImage], callbackf : @escaping  (JSON)->Void){
        
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/user/setProfile";
        self.JSONSend(url: url, param: fm_OriParam,Imgs: imgs , callbackf: callbackf)
    }
    
    //메인팝업
    func getAllPopup(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Popup/getAllPopup";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //푸시 seq 업데이트
    func updateLast(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Notification/updateLast";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //새로운 푸시가 있는지 체크
    func checkNew(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Notification/checkNew";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //푸시 토큰 업데이트
    func UserUpdateToken(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/user/UserUpdateToken";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //백그라운드 에서 포그라운드로 넘어왔을대
    func getWakeUpInfo(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/setting/getWakeUpInfo";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //휴먼계정 로그인
    func loginInactive(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/user/loginInactive";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //푸시 노티 클릭 했을때 트레이 상세 가는부분만 서버에서 재확인해서 하는작업
    func Notificationrestore(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Notification/restore";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //비밀번호 필수 변경
    func setPasswordForced(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/user/setPasswordForced";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //att 상태
    func setAttstatus(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Setting/setAttstatus";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    
    //지역번호
    func getPhonePrefixes(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/order/getPhonePrefixes";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //신규 회원가입 프로세스 이메일체크
    func NewEmailCheck(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        let fm_OriParam = ParamMerge(param : param);
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/user/chkEmailSite";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //신규 이메일 전송 신청 및 코드값 받기
    func NewEmailSendPlzRtsCode(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        
        let fm_OriParam = ParamMerge(param : param);
        
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/user/sendAuthEmailSite";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
    //통합회원 로그인
    func IntegratedLogin(param : [String : Any], callbackf : @escaping  (JSON)->Void){
        
        let fm_OriParam = ParamMerge(param : param);
        
        let url = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/user/loginSeqSite";
        self.JSONSend(url: url, param: fm_OriParam, callbackf: callbackf)
    }
//end===
}

