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
                    Picker("From",selection: $sourcelang) {
                        Text("Auto").tag("auto")
                        Text("Simplified Chinese").tag("zh")
                        Text("Traditional Chinese").tag("cht")
                        Text("English (US)").tag("en")
                        Text("日Japanese").tag("jp")
                        
                    }
                    Picker("To",selection: $targetlang) {
                        Text("Simplified Chinese").tag("zh")
                        Text("Traditional Chinese").tag("cht")
                        Text("English (US)").tag("en")
                        Text("日Japanese").tag("jp")
                    }
                }
                Section {
                    TextField("Type Text to Translate",text: $slang)
                }
                Section {
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
                                    translatedText="WARN: Request Failed"
                                    requesting=false
                                }else{
                                    let receiveddata=respond["trans_result"][0]["dst"].string ?? "WARN: Ruturned an Error"
                                    requesting=false
                                    sdata=respond["trans_result"][0]["src"].string ?? ""
                                    translatedText=receiveddata
                                    let currentlang=respond["from"].string
                                    if currentlang=="en"{
                                        dislang="English"
                                    } else if currentlang=="zh"{
                                        dislang="Simplified Chinese"
                                    } else if currentlang=="cht"{
                                        dislang="Traditional Chinese"
                                    } else if currentlang=="jp" {
                                        dislang="Japanese"
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
                                    translatedText="WARN: Request Failed"
                                    requesting=false
                                }else{
                                    let receiveddata=respond["trans_result"][0]["dst"].string ?? "WARN: Returned an Error"
                                    requesting=false
                                    sdata=respond["trans_result"][0]["src"].string ?? ""
                                    translatedText=receiveddata
                                    let currentlang=respond["from"].string
                                    if currentlang=="en"{
                                        dislang="English"
                                    } else if currentlang=="zh"{
                                        dislang="Simplified Chinese"
                                    } else if currentlang=="cht"{
                                        dislang="Traditional Chinese"
                                    } else if currentlang=="jp" {
                                        dislang="Japanese"
                                    }
                                    
                                }
                            }
                        } else{
                            requesting=false
                            translatedText="ERROR: Please Input APPID and Secert"
                        }
                    }, label: {
                        if requesting {
                            HStack{
                                Spacer()
                                Text("Requesting")
                                ProgressView()
                                Spacer()
                            }
                        } else{
                            HStack{
                                Spacer()
                                Image(systemName: "globe")
                                Text("Translate")
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
                                Spacer();Text("Translate From \(dislang):").frame(alignment: .center);Spacer()
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
                                                Text("Reset")
                                                Spacer()
                                            }
                                                      })
                        }
                    }
                }
                Section {
                    NavigationLink(destination:{SettingsView().navigationTitle("Settings")},label:{HStack{Spacer();Image(systemName: "gear")
                        Text("Settings");Spacer()}})
                    NavigationLink(destination:{AboutView().navigationTitle("About LWT")},label:{HStack{Spacer();Image(systemName: "info.circle")
                        Text("About");Spacer()
                    }})
                }

            }
            .navigationTitle("LWTranslate")
        }
    }
}


#Preview {
    ContentView()
}
