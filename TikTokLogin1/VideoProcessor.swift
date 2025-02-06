import AVFoundation
import UIKit

class VideoProcessor {
    enum VideoProcessingError: Error {
        case exportFailed
        case invalidAsset
        case compositionFailed
    }
    
    func clipAndStitchVideo(
        from sourceURL: URL,
        timeRanges: [CMTimeRange],
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        let asset = AVAsset(url: sourceURL)
        let composition = AVMutableComposition()
        
        guard let videoTrack = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ),
        let audioTrack = composition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            completion(.failure(VideoProcessingError.compositionFailed))
            return
        }
        
        // Get source tracks
        guard let sourceVideoTrack = asset.tracks(withMediaType: .video).first,
              let sourceAudioTrack = asset.tracks(withMediaType: .audio).first else {
            completion(.failure(VideoProcessingError.invalidAsset))
            return
        }
        
        var currentTime = CMTime.zero
        
        // Add each clip to the composition
        for timeRange in timeRanges {
            do {
                try videoTrack.insertTimeRange(
                    timeRange,
                    of: sourceVideoTrack,
                    at: currentTime
                )
                
                try audioTrack.insertTimeRange(
                    timeRange,
                    of: sourceAudioTrack,
                    at: currentTime
                )
                
                currentTime = CMTimeAdd(currentTime, timeRange.duration)
            } catch {
                completion(.failure(error))
                return
            }
        }
        
        // Create export session
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mp4")
        
        guard let exportSession = AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPresetHighestQuality
        ) else {
            completion(.failure(VideoProcessingError.exportFailed))
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                switch exportSession.status {
                case .completed:
                    completion(.success(outputURL))
                case .failed:
                    completion(.failure(exportSession.error ?? VideoProcessingError.exportFailed))
                default:
                    completion(.failure(VideoProcessingError.exportFailed))
                }
            }
        }
    }
} 