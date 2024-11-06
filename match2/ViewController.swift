//
//  ViewController.swift
//  match2
//
//  Created by Yekaterina Proskuryakova on 06.11.2024.
//

import UIKit

class ViewController: UIViewController {
    
    var images = ["1", "2", "3", "4", "5", "6", "7", "8", "1", "2", "3", "4", "5", "6", "7", "8"]
    
    var state = [Int](repeating: 0, count: 16)
    
    var winState = [[0,8],[1,9],[2,10],[3,11],[4,12],[5,13],[6,14],[7,15]]
    
    var isActive = false
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var playButton: UIButton!
    
    var time = 0
    
    var timer = Timer()
    
    var istimerRunning = false
    
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var movesLabel: UILabel!
    
    var moves = 0
    
    @IBOutlet weak var bestResultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func startGame(_ sender: Any) {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countTime), userInfo: nil, repeats: true)
        
        backgroundView.isHidden = true
        
        shuffleImages()
        
        winState.removeAll()
         
        for i in 0...15 {
            for j in i...15 {
                if images[i] == images[j] && i != j {
                    winState.append([i,  j])
                }
            }
            
        }
    }
    
    @objc func countTime() {
        time += 1
        timerLabel.text = timeString(time: time)
    }
    
    func countMoves() {
        moves += 1
        movesLabel.text = "Moves \(moves)"
    }
    
    func shuffleImages() {
        images.shuffle()
        
    }
    
    func bestResult() {
        let bestMoves = UserDefaults.standard.integer(forKey: "moves")
        
        let bestTime = UserDefaults.standard.integer(forKey: "time")
        
        bestResultLabel.text = "Best result \(bestMoves) moves in \(timeString(time: bestTime))"
    }
    
    @IBAction func game(_ sender: UIButton) {
        print(sender.tag)
        
        if state[sender.tag - 1] != 0 || isActive {
            return
        }
        
        sender.setBackgroundImage(UIImage(named: images[sender.tag - 1]), for: .normal)
        
        sender.backgroundColor = UIColor.white
        
        state[sender.tag - 1] = 1
        
        var count = 0
        
        for item in state {
            if item == 1 {
                count += 1
            }
        }
        
        if count == 2 {
            countMoves()
            isActive = true
            for winArray in winState {
                if state[winArray[0]] == state[winArray[1]] && state[winArray[1]] == 1 {
                    state[winArray[0]] = 2
                    state[winArray[1]] = 2
                    isActive = false
                }
                
            }
            if isActive {
                Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(clear), userInfo: nil, repeats: false)
            }
            
        }
        
        var isFinish = !state.contains(0)
        
        if isFinish {
            timer.invalidate()
            
            let bestMoves = UserDefaults.standard.integer(forKey: "moves")
            
            let bestTime = UserDefaults.standard.integer(forKey: "time")
            
            if (bestMoves == 0 && bestTime == 0) || bestMoves > moves && bestTime > time {
                UserDefaults.standard.setValue(moves,forKey: "moves")
                
                UserDefaults.standard.setValue (time,forKey: "time")
            }
            
            let alert = UIAlertController(title: "You win!", message: "You win with \(moves) moves in \( timeString(time: time))", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
                UIAlertAction in
                
                self.clearGame()
            }))
            
            present(alert, animated: true)
        }

    }
    
    @objc func clear() {
        for i in 0...15 {
            if state[i] == 1 {
                state[i] = 0
                let button = view.viewWithTag(i + 1) as! UIButton
                button.setBackgroundImage(nil, for: .normal)
                button.backgroundColor = UIColor.systemMint
            }
        }
        
        isActive = false
    }
    
    func clearGame() {
        for i in 0...15 {
            state[i] = 0
            let button = view.viewWithTag(i + 1) as! UIButton
            button.setBackgroundImage(nil, for: .normal)
            button.backgroundColor = UIColor.systemMint
        }
        isActive = false
        timer.invalidate()
        time = 0
        timerLabel.text = "00:00:00"
        moves = 0
        movesLabel.text = "Moves: 0"
        backgroundView.isHidden = false
        playButton.setTitle("Play again", for: .normal)
        bestResult()
    }
    
    func timeString(time: Int) -> String {
        let hour = time / 3600
        let minute = time / 60 % 60
        let second = time % 60

        // return formated string
        return String(format: "%02i:%02i:%02i", hour, minute, second)
    }
}
