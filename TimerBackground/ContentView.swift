//
//  ContentView.swift
//  TimerBackground
//
//  Created by Miguel Planckensteiner on 12.05.20.
//  Copyright © 2020 Miguel Planckensteiner. All rights reserved.
//
import SwiftUI
import UserNotifications

struct ContentView: View {
    var body: some View {
        TimerView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct TimerView: View {
    @State var start = false
    @State var to: CGFloat = 0
    @State var count = 0
    @State var countDiff = 0
    
    
    @State var time = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var notificationPublisher = NotificationPublisher()
    
    
    var body: some View {
        
        ZStack {
            
            Color.black.opacity(0.20).edgesIgnoringSafeArea(.all)
            
            VStack {
                
                VStack(spacing: 0) {
                    Text("Easy Timer")
                        .font(.system(size: 60, design: .rounded))
                        .fontWeight(.black)
                        .padding(.bottom, 40)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .trim(from: 0, to: 1)
                        .stroke(Color.black.opacity(0.3), style: StrokeStyle(lineWidth: 60, lineCap: .round))
                        .frame(width: 280, height: 280)
                    
                    Circle()
                        .trim(from: 0, to: self.to)
                        .stroke(Color.orange, style: StrokeStyle(lineWidth: 60, lineCap: .round))
                        .frame(width: 280, height: 280)
                        .rotationEffect(.init(degrees: -90))
                    
                    VStack {
                        Text("\(self.count)")
                            .font(.system(size: 70, design: .rounded))
                            .foregroundColor(.orange)
                            .fontWeight(.bold)
                        
                        Text("/ 60")
                            .font(.system(size: 35, design: .rounded))
                            .fontWeight(.bold)
                            .padding(.top)
                    }
                }
                HStack (spacing: 30) {
                    
                    //Play/Pause Button
                    Button(action: {
                        if self.count == 60 {
                            
                            self.time.upstream.connect().cancel()
                            self.count = 0
                            self.countDiff = 0
                            withAnimation(.default) {
                                self.to = 0
                            }
                            //Stop Local Notifications
                            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                        }
                        self.start.toggle()
                        self.setupLocalNotificationsFor()
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: self.start ? "pause.fill" : "play.fill")
                                .foregroundColor(Color.white)
                            Text (self.start ? "Pause" : "Play")
                                .foregroundColor(Color.white)
                        }
                        .padding(.vertical)
                        .frame(width: (UIScreen.main.bounds.width / 2) - 60)
                        .background(Color.orange)
                        .clipShape(Capsule())
                        .shadow(radius: 7)
                    }
                    //Reset Button
                    Button(action: {
                        removeSavedDate()
                        self.count = 0
                        self.countDiff = 0
                        withAnimation(.default) {
                            self.to = 0
                        }
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.orange)
                            Text("Restart")
                                .foregroundColor(.orange)
                        }
                        .padding(.vertical)
                        .frame(width: (UIScreen.main.bounds.width / 2) - 60)
                        .background(Capsule()
                        .stroke(Color.orange, lineWidth: 4))
                        .shadow(radius: 7)
                        
                    }
                    
                }//end of HStack
                    .padding(.top, 60)
                Spacer()
            }
        }//end of ZStack
            //Will come back to Foreground
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) {_ in
                
                print("App returning to the foreground")
                if let saveDate = UserDefaults.standard.object(forKey: "saveTime") as? Date {
                    (self.countDiff) = getTimeDifference(startDate: saveDate)
                    
                    self.refresh(seconds: self.countDiff)
                    
                    if self.countDiff >= 60 || self.count >= 60 || self.start == false {
                        
                        removeSavedDate()
                        self.count = 0
                        self.countDiff = 0
                        self.to = 0
                        self.start = false
                        
                        //Stop Local Notifications
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    }
                    
                } else {
                    removeSavedDate()
                    self.time.upstream.connect().cancel()
                    
                }
                
                
        }
            //Will go to background
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) {_ in
                
                print("App going to the background")
                let shared = UserDefaults.standard
                shared.set(Date(), forKey: "saveTime")
                print(Date())
        }
        .onReceive(self.time) {(_) in
            if self.start{
                if self.count != 60 {
                    self.count += 1
                    print(self.count)
                    withAnimation(.default) {
                        self.to = CGFloat(self.count) / 60
                    }
                } else {
                    self.start.toggle()
                    //Stop Local Notifications
                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                }
            }
        }
    }
    func refresh(seconds: Int) {
        self.count += seconds
        self.time = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    }
    func setupLocalNotificationsFor() {
        
        let countInterval = 60
        
        notificationPublisher.sendNotification(title:"Important Message", subtitle: "", body: "The timer has ended up!☺️", delayInterval: countInterval)
    }
}//end of TimerView

//Helpers

func getTimeDifference(startDate: Date) -> (Int){
    let calendar = Calendar.current
    let components = calendar.dateComponents([.hour, .minute, .second], from: startDate, to: Date())
    return (components.second!)
}

func removeSavedDate(){
    if (UserDefaults.standard.object(forKey: "saveTime") as? Date) != nil{
        UserDefaults.standard.removeObject(forKey: "saveTime")
    }
}
