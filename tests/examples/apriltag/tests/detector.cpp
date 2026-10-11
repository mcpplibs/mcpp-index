#include <cassert>

#include <apriltag.h>
#include <common/image_u8.h>
#include <tagStandard41h12.h>

int main() {
    apriltag_detector_t* detector = apriltag_detector_create();
    assert(detector != nullptr);
    assert(detector->nthreads > 0);

    apriltag_family_t* family = tagStandard41h12_create();
    assert(family != nullptr);
    assert(family->ncodes > 0);
    apriltag_detector_add_family(detector, family);

    image_u8_t* image = image_u8_create(64, 64);
    assert(image != nullptr);
    zarray_t* detections = apriltag_detector_detect(detector, image);
    assert(detections != nullptr);
    assert(zarray_size(detections) == 0);

    apriltag_detections_destroy(detections);
    image_u8_destroy(image);
    apriltag_detector_destroy(detector);
    tagStandard41h12_destroy(family);
    return 0;
}
