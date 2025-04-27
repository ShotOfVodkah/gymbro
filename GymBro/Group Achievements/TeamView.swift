//
//  TeamView.swift
//  GymBro
//
//  Created by Александра Грицаенко on 27/04/2025.
//

import SwiftUI

struct TeamView: View {
    var team: Teams
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            TeamTitleRow
        }
        .navigationBarHidden(true)
    }
    
    private var TeamTitleRow: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .font(.system(size: 30))
                    .padding(.leading)
            }
            Image(systemName: "figure.2.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.white)
            VStack(alignment: .leading) {
                Text("\(team.team_name)")
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundColor(.white)
            }
            Spacer()
            NavigationLink {
                Challenges(team_id: team.id)
            } label: {
                VStack(alignment: .trailing) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                    Text("Add challenge")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.trailing)
                .padding(.vertical)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.linearGradient(colors: [Color("PurpleColor"), .purple], startPoint: .leading, endPoint: .trailing))
    }
}

#Preview {
    let data = ["id": "Sf7roo3RSbDkuaiSqY9d",
                "team_name": "My first team",
                "owner": "g9wEOL71fNeTFlLcEhhzWHua1wK2",
                "members": ["v2vtxsjwRHNvazfmMHN2EUZz4U83", "Ssw2gP6bBPVOCzMLzrmQkGWMGx42", "H7BSrUZffMgXJVOdgy3mITSuU7p1", "g9wEOL71fNeTFlLcEhhzWHua1wK2"],
                "created_at": Date()]
    TeamView(team: Teams(data: data))
}
