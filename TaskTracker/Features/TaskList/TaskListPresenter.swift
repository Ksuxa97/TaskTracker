//
//  TaskListPresenter.swift
//  TaskTracker
//
//  Created by Kseniya Semenova on 27.09.2025.
//

import Foundation
import UIKit

final class TaskListPresenter: TaskListPresenterProtocol {

    weak var view: TaskListViewControllerProtocol?
    weak var interactor: TaskListInteractorProtocol?
    weak var router: TaskListRouterProtocol?

    var numberOfItems: Int {
        return tasks.count
    }

    private var tasks: [Task] = [Task(id:1,name:"Do something nice for someone you care about",description:"",createdAt:Date(),isCompleted:false,userId:152),Task(id:2,name:"Memorize a poem",description:"",createdAt:Date(),isCompleted:true,userId:13),Task(id:3,name:"Watch a classic movie",description:"",createdAt:Date(),isCompleted:true,userId:68),Task(id:4,name:"Watch a documentary",description:"",createdAt:Date(),isCompleted:false,userId:84),Task(id:5,name:"Invest in cryptocurrency",description:"",createdAt:Date(),isCompleted:false,userId:163),Task(id:6,name:"Contribute code or a monetary donation to an open-source software project",description:"",createdAt:Date(),isCompleted:false,userId:69),Task(id:7,name:"Solve a Rubik's cube",description:"",createdAt:Date(),isCompleted:true,userId:76),Task(id:8,name:"Bake pastries for yourself and neighbor",description:"",createdAt:Date(),isCompleted:true,userId:198),Task(id:9,name:"Go see a Broadway production",description:"",createdAt:Date(),isCompleted:false,userId:7),Task(id:10,name:"Write a thank you letter to an influential person in your life",description:"",createdAt:Date(),isCompleted:true,userId:9),Task(id:11,name:"Invite some friends over for a game night",description:"",createdAt:Date(),isCompleted:false,userId:104),Task(id:12,name:"Have a football scrimmage with some friends",description:"",createdAt:Date(),isCompleted:false,userId:32),Task(id:13,name:"Text a friend you haven't talked to in a long time",description:"",createdAt:Date(),isCompleted:true,userId:2),Task(id:14,name:"Organize pantry",description:"",createdAt:Date(),isCompleted:false,userId:46),Task(id:15,name:"Buy a new house decoration",description:"",createdAt:Date(),isCompleted:true,userId:105),Task(id:16,name:"Plan a vacation you've always wanted to take",description:"",createdAt:Date(),isCompleted:true,userId:162),Task(id:17,name:"Clean out car",description:"",createdAt:Date(),isCompleted:false,userId:71),Task(id:18,name:"Draw and color a Mandala",description:"",createdAt:Date(),isCompleted:true,userId:6),Task(id:19,name:"Create a cookbook with favorite recipes",description:"",createdAt:Date(),isCompleted:true,userId:53),Task(id:20,name:"Bake a pie with some friends",description:"",createdAt:Date(),isCompleted:false,userId:162),Task(id:21,name:"Create a compost pile",description:"",createdAt:Date(),isCompleted:false,userId:13),Task(id:22,name:"Take a hike at a local park",description:"",createdAt:Date(),isCompleted:true,userId:37),Task(id:23,name:"Take a class at local community center that interests you",description:"",createdAt:Date(),isCompleted:true,userId:65),Task(id:24,name:"Research a topic interested in",description:"",createdAt:Date(),isCompleted:true,userId:130),Task(id:25,name:"Plan a trip to another country",description:"",createdAt:Date(),isCompleted:false,userId:140),Task(id:26,name:"Improve touch typing",description:"",createdAt:Date(),isCompleted:false,userId:178),Task(id:27,name:"Learn Express.js",description:"",createdAt:Date(),isCompleted:false,userId:194),Task(id:28,name:"Learn calligraphy",description:"",createdAt:Date(),isCompleted:false,userId:80),Task(id:29,name:"Have a photo session with some friends",description:"",createdAt:Date(),isCompleted:true,userId:91),Task(id:30,name:"Go to the gym",description:"",createdAt:Date(),isCompleted:true,userId:142)]

    init() {
    }

    func getItem(with index: Int) -> Task {
        return tasks[index]
    }

    func didSelectTask(at index: Int) {
        guard let taskListVC = view as? UIViewController else { return }
        if router == nil {
            print("router is not initialized")
        }
        router?.navigateToEditTask(from: taskListVC, with: tasks[index])
    }

    func updateTaskList() {

    }
}
