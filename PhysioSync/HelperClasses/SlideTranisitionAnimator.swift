//
//  PatientOnboardingVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 22/05/24.
//

import UIKit

class SlideTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let isPresenting: Bool

    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 // Set the duration of the animation
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
              let toViewController = transitionContext.viewController(forKey: .to) else {
            return
        }
        let containerView = transitionContext.containerView

        let screenWidth = containerView.bounds.width
        let translation = isPresenting ? screenWidth : -screenWidth

        if isPresenting {
            containerView.addSubview(toViewController.view)
            toViewController.view.transform = CGAffineTransform(translationX: translation, y: 0)
        }

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromViewController.view.transform = CGAffineTransform(translationX: -translation, y: 0)
            toViewController.view.transform = .identity
        }) { (_) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
