//
//  ContentView.swift
//  Linecom Wear Translate Watch App
//
//  Created by 澪空 on 2024/3/1.
//

import SwiftUI
import DarockKit
import CommonCrypto

struct ContentView: View {
    @State var slang = ""
    @AppStorage("RememberLast") var lastenable=true
    @State var translatedText = ""
    @State var appid="20221006001373645"
    @State var apikey="7YH2L_U7dSHwqq6OErqB"
    @AppStorage("CustomAppid") var custid=""
    @AppStorage("CustomKey") var custkey=""
    @AppStorage("ApiKeyStatus") var custkeyenable=false
    @State var dislang=""
    @State var sdata=""
    @State var requesting=false
    @AppStorage("LastSource") var sourcelang="auto"
    @AppStorage("LastTarget") var targetlang="en"
    
    var body: some View {
        //搁置
        //if !lastenable{
         //   var sourcelang="auto"
        //    var targetlang="en"
        //}
        NavigationStack {
            List {
                Section {
                    Picker("源语言",selection: $sourcelang) {
                        Text("自动").tag("auto")
                        Text("简体中文").tag("zh")
                        Text("繁体中文").tag("cht")
                        Text("英语").tag("en")
                        Text("日语").tag("jp")
                        Text("韩语").tag("kor")
                        Text("法语").tag("fra")
                        Text("德语").tag("de")
                        Text("俄语").tag("ru")
                        
                    }
                    Picker("目标语言",selection: $targetlang) {
                        Text("简体中文").tag("zh")
                        Text("繁体中文").tag("cht")
                        Text("英语").tag("en")
                        Text("日语").tag("jp")
                        Text("韩语").tag("kor")
                        Text("法语").tag("fra")
                        Text("德语").tag("de")
                        Text("俄语").tag("ru")
                    }
                    TextField("键入源语言",text: $slang)
                    Button(action: {
                        // ...
                        requesting = true
                        if !custkeyenable{
                        let clipedkey=appid+slang+"1355702100"+apikey
                        let signtrue=clipedkey.md5c()
                        let all="q=\(slang)&from=\(sourcelang)&to=\(targetlang)&appid=\(appid)&salt=1355702100&sign=\(signtrue)"
                            print(all)
                        let allurl="https://fanyi-api.baidu.com/api/trans/vip/translate?\(all)"
                            DarockKit.Network.shared.requestJSON(allurl.urlEncoded()){ respond, succeed in
                                if !succeed{
                                    translatedText="WARN: 翻译请求失败"
                                    requesting=false
                                }else{
                                    let receiveddata=respond["trans_result"][0]["dst"].string ?? "WARN: 翻译返回错误"
                                    requesting=false
                                    sdata=respond["trans_result"][0]["src"].string ?? ""
                                    translatedText=receiveddata
                                    let currentlang=respond["from"].string
                                    if currentlang=="en"{
                                        dislang="英语"
                                    } else if currentlang=="zh"{
                                        dislang="简体中文"
                                    } else if currentlang=="cht"{
                                        dislang="繁体中文"
                                    } else if currentlang=="jp" {
                                        dislang="日语"
                                    } else if currentlang=="kor"{
                                        dislang="韩语"
                                    } else if currentlang=="fra"{
                                        dislang="法语"
                                    } else if currentlang=="de"{
                                        dislang="德语"
                                    } else if currentlang=="ru"{
                                        dislang="俄语"
                                    }
                                    
                                }
                            }
                        }else if !custid.isEmpty && !custkey.isEmpty{
                            let clipedcustkey=custid+slang+"1355702100"+custkey
                            let custsigntrue=clipedcustkey.md5c()
                            let custall="q=\(slang)&from=\(sourcelang)&to=\(targetlang)&appid=\(custid)&salt=1355702100&sign=\(custsigntrue)"
                            print(custall)
                            let custallurl="https://fanyi-api.baidu.com/api/trans/vip/translate?\(custall)"
                            DarockKit.Network.shared.requestJSON(custallurl.urlEncoded()){ respond, succeed in
                                if !succeed{
                                    translatedText="WARN: 翻译请求失败"
                                    requesting=false
                                }else{
                                    let receiveddata=respond["trans_result"][0]["dst"].string ?? "WARN: 翻译返回错误"
                                    requesting=false
                                    sdata=respond["trans_result"][0]["src"].string ?? ""
                                    translatedText=receiveddata
                                    let currentlang=respond["from"].string
                                    if currentlang=="en"{
                                        dislang="英语"
                                    } else if currentlang=="zh"{
                                        dislang="简体中文"
                                    } else if currentlang=="cht"{
                                        dislang="繁体中文"
                                    } else if currentlang=="jp" {
                                        dislang="日语"
                                    } else if currentlang=="kor"{
                                        dislang="韩语"
                                    } else if currentlang=="fra"{
                                        dislang="法语"
                                    } else if currentlang=="de"{
                                        dislang="德语"
                                    } else if currentlang=="ru"{
                                        dislang="俄语"
                                    }
                                    
                                }
                            }
                        } else{
                            requesting=false
                            translatedText="ERROR:请输入APPID与密钥"
                        }
                    }, label: {
                        if requesting {
                            HStack{
                                Spacer()
                                Text("正在请求")
                                ProgressView()
                                Spacer()
                            }
                        } else{
                            HStack{
                                Spacer()
                                Image(systemName: "globe")
                                Text("翻译")
                                Spacer()
                            }
                        }
                        
                        
                    })
                    
                }
                if !translatedText.isEmpty {
                    VStack{
                        Section {
                            HStack{
                                Spacer();Text(sdata).frame(alignment: .center);Spacer()
                            }
                            HStack{
                                Spacer();Text("从\(dislang)翻译：").frame(alignment: .center);Spacer()
                            }
                            HStack{
                                Spacer();Text(translatedText).frame(alignment: .center);Spacer()
                            }
                        }
                    }
                    .padding()
                    VStack{
                        Section{
                            Button(action:{translatedText=""
                                slang=""
                            dislang=""},label:{
                                            HStack{
                                                Spacer()
                                                Image(systemName: "restart")
                                                Text("重置")
                                                Spacer()
                                            }
                                                      })
                        }
                    }
                }
                Section {
                    NavigationLink(destination:{SettingsView().navigationTitle("设置")},label:{HStack{Spacer();Image(systemName: "gear")
                        Text("设置");Spacer()}})
                    NavigationLink(destination:{AboutView().navigationTitle("关于LWT")},label:{HStack{Spacer();Image(systemName: "info.circle")
                        Text("关于");Spacer()
                    }})
                }

            }
            .navigationTitle("LWT翻译")
        }
    }
}


#Preview {
    ContentView()
}
