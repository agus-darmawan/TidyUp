//
//  TabRouter.swift
//  TidyUp
//
//  Lets any screen (e.g. Dashboard's "See All" links) jump to a different
//  main tab, instead of every tab being a dead end.
//

import Observation

@Observable
final class TabRouter {
    enum Tab: Int {
        case home = 0, tasks = 1, money = 2, more = 3
    }

    var selectedTab: Int = Tab.home.rawValue

    func go(to tab: Tab) {
        selectedTab = tab.rawValue
    }
}
