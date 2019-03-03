//
//  CardDetailViewController.swift
//  Lincoln Laws
//
//  Created by Christopher Perkins on 3/2/19.
//  Copyright © 2019 Christopher Perkins. All rights reserved.
//

import ClingConstraints
import CoreLocation
import UIKit
import Lottie

public class CardDetailViewController: UIViewController {
    @IBOutlet weak var loadingContainerView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var descriptionContainer: UIView!
    @IBOutlet weak var noSummaryAvailableLabel: UILabel! {
        didSet {
            if let summary = billToDisplay?.summary {
                noSummaryAvailableLabel?.text = summary
            }
        }
    }
    @IBOutlet weak var summaryContainer: UIView!
    @IBOutlet weak var loadingAnimationView: LOTAnimationView! {
        didSet {
            loadingAnimationView.loopAnimation = true
            loadingAnimationView.play()
        }
    }

    public var billToDisplay: Bill? {
        didSet {
            guard let bill = billToDisplay else {
                partySponsorLottieView?.animation = nil
                return
            }
            if bill.sponsorParty == .democrat {
                partySponsorLottieView?.setAnimation(named: "republican")
                sponsorLabel?.text = "Sponsoring Party: Republican"
            } else {
                partySponsorLottieView?.setAnimation(named: "democrat")
                sponsorLabel?.text = "Sponsoring Party: Democrat"
            }
            titleLabel?.text = bill.shortTitle
            descriptionLabel?.text = bill.title

            if let summary = billToDisplay?.summary {
                noSummaryAvailableLabel?.text = summary
            }

            LincolnLawsServer.shared.getFullText(bill: bill, successHandler: { (fulldata) in
                self.billFullText = fulldata
            }) { (_, _, _) in
                print(":!:!:")
                self.billFullText = nil
            }
        }
    }

    public var billFullText: BillFullTextData? {
        didSet {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2, animations: {
                    if (self.billFullText?.preamble ?? "").isEmpty && (self.billFullText?.resolutionBody ?? "").isEmpty {
                        self.summaryContainer.isHidden = false
                    } else {
                        self.descriptionContainer.isHidden = false
                    }
                    self.loadingContainerView.isHidden = true
                    self.stackView.layoutIfNeeded()
                })
                self.preambleText?.text = self.billFullText?.preamble
                self.resolutionText?.text = self.billFullText?.resolutionBody
            }
        }
    }
    @IBOutlet weak var preambleText: UILabel! {
        didSet {
            preambleText?.text = billFullText?.preamble
        }
    }
    @IBOutlet weak var resolutionText: UILabel! {
        didSet {
            resolutionText?.text = billFullText?.resolutionBody
        }
    }

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            guard let bill = billToDisplay else {
                partySponsorLottieView?.animation = nil
                return
            }
            titleLabel?.text = bill.shortTitle
        }
    }

    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            guard let bill = billToDisplay else {
                return
            }
            descriptionLabel?.text = bill.title
        }
    }

    @IBOutlet weak var closeButton: UIButton! {
        didSet {
            closeButton.layer.shadowColor = UIColor.white.cgColor
            closeButton.layer.shadowOffset = CGSize.zero
            closeButton.layer.shadowRadius = 4
            closeButton.layer.shadowOpacity = 1
        }
    }
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var animationViewContainer: UIView! {
        didSet {
            partySponsorLottieView = LOTAnimationView(frame: .zero)
            animationViewContainer.addSubview(partySponsorLottieView!)
            partySponsorLottieView?.copy(.top, .left, .bottom, .right, of: animationViewContainer)
        }
    }

    override public var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }

    @IBOutlet weak var sponsorLabel: UILabel! {
        didSet {
            guard let bill = billToDisplay else {
                partySponsorLottieView?.animation = nil
                return
            }
            if bill.sponsorParty == .democrat {
                sponsorLabel?.text = "Sponsoring Party: Republican"
            } else {
                sponsorLabel?.text = "Sponsoring Party: Democrat"
            }
        }
    }

    public var partySponsorLottieView: LOTAnimationView? {
        didSet {
            guard let bill = billToDisplay else {
                partySponsorLottieView?.animation = nil
                return
            }
            if bill.sponsorParty == .democrat {
                partySponsorLottieView?.setAnimation(named: "republican")
            } else {
                partySponsorLottieView?.setAnimation(named: "democrat")
            }
        }
    }
}
