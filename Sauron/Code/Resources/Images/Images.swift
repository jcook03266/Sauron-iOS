//
//  Images.swift
//  Inspec
//
//  Created by Justin Cook on 10/31/22.
//

import UIKit
import SwiftUI

/// Image / icon selector for picking out all enumerated images stored in the corresponding Images xcassets file
/// Please update the appropriate enumerations whenever an image is added or removed from the xcassets
// MARK: - Structs
struct Images {
    static func getImage(named imageName: ImageRepository) -> Image {
        return Image(uiImage: getUIImage(named: imageName))
    }
    
    static func getUIImage(named imageName: ImageRepository) -> UIImage {
        guard let image = UIImage(named: imageName.rawValue) else {
            
            preconditionFailure("Error: The image named \(imageName) was not found, Function: \(#function)")
        }
        
        return image
    }
}

/// Use this struct to select custom or system icons
struct Icons {
    static func getIconImage(named customName: CustomIconRepository,
                             renderingMode: Image.TemplateRenderingMode = .template) -> Image {
        return Image(uiImage: getIconUIImage(named: customName))
            .renderingMode(renderingMode)
    }
    
    static func getIconUIImage(named customName: CustomIconRepository,
                               renderingMode: UIImage.RenderingMode = .alwaysTemplate) -> UIImage {
        guard let image = UIImage(named: customName.rawValue) else {
            
            preconditionFailure("Error: The custom icon named \(customName) was not found, Function: \(#function)")
        }
        
        image.withRenderingMode(renderingMode)
        
        return image
    }
    
    static func getIconImage(named systemName: SystemIconRepository,
                             renderingMode: Image.TemplateRenderingMode = .template) -> Image {
        
        return Image(systemName: systemName.rawValue)
            .renderingMode(renderingMode)
    }
    
    static func getIconUIImage(named systemName: SystemIconRepository,
                               renderingMode: UIImage.RenderingMode = .alwaysTemplate) -> UIImage {
        guard let image = UIImage(systemName: systemName.rawValue) else {
            
            preconditionFailure("Error: The system icon named \(systemName) was not found, Function: \(#function)")
        }
        
        image.withRenderingMode(renderingMode)
        
        return image
    }
}

// MARK: - Image Enumerations
enum ImageRepository: String, CaseIterable, Hashable {
    case coin_cluster_background_graphic = "coin.cluster.background.graphic",
         two_tone_dot_matrix_background_graphic = "two.tone.dot.matrix.background.graphic",
         launchscreen_background = "launchscreen-background"
}

enum CustomIconRepository: String, CaseIterable, Hashable {
    case wallet,
         app_icon_transparent = "app-icon-transparent"
}

enum SystemIconRepository: String, CaseIterable, Hashable {
    case abc,
         textformat_abc = "textformat.abc",
         eye,
         tag_fill = "tag.fill",
         tag,
         arrowtriangle_up_fill = "arrowtriangle.up.fill",
         arrowtriangle_down_fill = "arrowtriangle.down.fill",
         dollarsign_square_fill = "dollarsign.square.fill",
         eye_circle = "eye.circle",
         eye_circle_fill = "eye.circle.fill",
         eye_fill = "eye.fill",
         eye_trianglebadge_exclamationmark_fill = "eye.trianglebadge.exclamationmark.fill",
         eye_slash = "eye.slash",
         eye_slash_fill = "eye.slash.fill",
         eye_slash_circle = "eye.slash.circle",
         eye_slash_circle_fill = "eye.slash.circle.fill",
         chevron_left = "chevron.left",
         chevron_right = "chevron.right",
         chevron_up = "chevron.up",
         chevron_down = "chevron.down",
         chevron_left_2 = "chevron.left.2",
         chevron_right_2 = "chevron.right.2",
         chevron_compact_down = "chevron.compact.down",
         chevron_compact_up = "chevron.compact.up",
         arrow_up = "arrow.up",
         arrow_down = "arrow.down",
         arrow_right = "arrow.right",
         arrow_left = "arrow.left",
         ellipsis = "ellipsis",
         square = "square",
         checkmark_square_fill = "checkmark.square.fill",
         plus_circle = "plus.circle",
         minus_circle = "minus.circle",
         plus_circle_fill = "plus.circle.fill",
         xmark_circle_fill = "xmark.circle.fill",
         checkmark_circle_fill = "checkmark.circle.fill",
         plus = "plus",
         minus = "minus",
         checkmark = "checkmark",
         xmark = "xmark",
         paperplane = "paperplane",
         square_grid_2x2 = "square.grid.2x2",
         doc = "doc",
         book = "book",
         text_bubble = "text.bubble",
         bubble_left = "bubble.left",
         square_and_pencil = "square.and.pencil",
         bell = "bell",
         clock = "clock",
         questionmark_circle = "questionmark.circle",
         questionmark_square_dashed = "questionmark.square.dashed",
         exclamationmark_triangle = "exclamationmark.triangle",
         lock,
         lock_fill = "lock.fill",
         key,
         link,
         creditcard,
         wifi_slash = "wifi.slash",
         person_fill = "person.fill",
         person_crop_circle_badge_plus = "person.crop.circle.badge.plus",
         heart,
         heart_fill = "heart.fill",
         hand_thumbsup = "hand.thumbsup",
         hand_thumbsup_fill = "hand.thumbsup.fill",
         hand_thumbsdown = "hand.thumbsdown",
         hand_thumbsdown_fill = "hand.thumbsdown.fill",
         star = "star",
         star_fill = "star.fill",
         play_circle_fill = "play.circle.fill",
         gobackward = "gobackward",
         magnifyingglass = "magnifyingglass",
         plus_square_on_square = "plus.square.on.square",
         square_and_arrow_up = "square.and.arrow.up",
         square_and_arrow_down = "square.and.arrow.down",
         gear,
         bolt_fill = "bolt.fill",
         bolt_slash_fill = "bolt.slash.fill",
         bolt_badge_a_fill = "bolt.badge.a.fill",
         stop_circle = "stop.circle",
         rays = "rays",
         arrow_counterclockwise = "arrow.counterclockwise",
         arrow_clockwise = "arrow.clockwise",
         arrow_triangle_2_circlepath = "arrow.triangle.2.circlepath",
         arrow_2_squarepath = "arrow.2.squarepath",
         rectangle_portrait_and_arrow_right = "rectangle.portrait.and.arrow.right",
         face_smiling = "face.smiling",
         wand_and_stars = "wand.and.stars",
         gauge = "gauge",
         crown = "crown",
         megaphon = "megaphone",
         tray = "tray",
         house = "house",
         point_3_connected_trianglepath_dotted = "point.3.connected.trianglepath.dotted",
         point_3_filled_connected_trianglepath_dotted = "point.3.filled.connected.trianglepath.dotted",
         circle_hexagongrid_fill = "circle.hexagongrid.fill",
         aqi_medium = "aqi.medium",
         rectangle_3_group_fill = "rectangle.3.group.fill",
         line_3_horizontal_decrease_circle_fill = "line.3.horizontal.decrease.circle.fill",
         info_circle_fill = "info.circle.fill",
         list_number = "list.number",
         flame_fill = "flame.fill",
         faceid,
         delete_backward_fill = "delete.backward.fill",
         bitcoinsign_circle_fill = "bitcoinsign.circle.fill",
         cloud_sun_bolt_fill = "cloud.sun.bolt.fill"
         
}
