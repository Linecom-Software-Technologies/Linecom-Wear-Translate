//
//  AboutView.swift
//  Linecom Wear Translate Watch App
//
//  Created by 澪空 on 2024/3/2.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        TabView{
            AppAbout()
            CerditView().navigationTitle("Credits")
            OSPView().navigationTitle("OSSLicense")
        }
    }
}
struct AppAbout: View{
    var body: some View{
        VStack{
            HStack{
                Image("abouticon").resizable().scaledToFit()
                Text("Linecom Wear Translate").padding()
            }
            Text("Developed by Linecom").padding()
            Text("License under MIT.").font(.custom("", size: 12))
            //Text("浙ICP备00000000号-0A").font(.custom("", size: 11))
            //Text("*备案审核进行中，暂时作为PlaceHolder").font(.custom("", size: 6))
        }
    }
}
struct CerditView: View{
    var body: some View{
        List{
            Section{
                    HStack{
                        Image("MEMZAvatar").resizable().scaledToFit().frame(width:43,height:43)
                        Text("WindowsMEMZ")
                    }
            }
        }
    }
}
struct OSPView: View{
    var body: some View{
        List{
            Text("SwiftyJSON\nLicense under MIT")
            Text("Alamofire\nLicense under MIT")
            Text("SFSymbol\nLicense under MIT")
        }
    }
}
struct SettingsView: View{
    @AppStorage("RememberLast") var lastenable=true
    var body: some View{
            NavigationStack{
                Section{
                    NavigationLink(destination:{apiconfigView().navigationTitle("Config Secert")},label:{Text("Config API Secert")})
                    
                }
                Section{
                    NavigationLink(destination:{SupportView().navigationTitle("Contact Us")},label:{Text("Contact and Feedback")})
                }
            }
            //搁置
            //Section{
            //    Toggle("记录上次语言",isOn: $lastenable)
            //}footer:{
            //       Text("打开此选项，LWT将会记住您上次所用的语言。")
            //    }
    }
}
struct apiconfigView: View{
    @AppStorage("ApiKeyStatus") var customkeyenable=false
    @AppStorage("CustomAppid") var custid=""
    @AppStorage("CustomKey") var custkey=""
    var body: some View{
        List{
            Section{
                Text("Overview:")
                Text("Starting from August 1, 2022, Baidu Translate will limit the monthly free call limit to 1 million characters. If you have your own key, you can replace the default key provided by Linecom here")
            }
            Section{
                Toggle("Use own API key",isOn: $customkeyenable)
            }
            if customkeyenable{
                
                Section{
                    TextField("APPID",text: $custid)
                    TextField("Secert",text: $custkey)
                }
            }
        }
    }
}
struct SupportView: View{
    var body: some View{
        List{
            Text("Contact us via Email")
            Text("linecom@linecom.net.cn").font(.custom("", size: 15))
            Text("If you have trouble using, please send a ticket to us:")
            Text("support@linecom.net.cn").font(.custom("", size: 15))
        }
    }
}

#Preview {
    AboutView()
}
