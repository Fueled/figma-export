# Returns the current short version, only by reading the last tag.
def short_version_from_tag()
    UI.important("Setting short_version from most recent tag")
    last_tag = fetch_last_tag
    last_tag = (last_tag.nil? || last_tag.empty?) ?  "v0.0.0" : last_tag
    last_tag[1..-1]
end

# Bump a given semver version, by incrementing the appropriate
# component, as per the bump_type (patch, minor, major, or none).
def bump_semver(semver:, bump_type:)
    splitted_version = {
    major: semver.split('.').map(&:to_i)[0] || 0,
    minor: semver.split('.').map(&:to_i)[1] || 0,
    patch: semver.split('.').map(&:to_i)[2] || 0
    }
    case bump_type
    when "patch"
    splitted_version[:patch] = splitted_version[:patch] + 1
    when "minor"
    splitted_version[:minor] = splitted_version[:minor] + 1
    splitted_version[:patch] = 0
    when "major"
    splitted_version[:major] = splitted_version[:major] + 1
    splitted_version[:minor] = 0
    splitted_version[:patch] = 0
    end
    [splitted_version[:major], splitted_version[:minor], splitted_version[:patch]].map(&:to_s).join('.')
end

# Returns the last tag in the repo
def fetch_last_tag()
    tag = nil
    git_cmd = "git tag -l --sort=-v:refname | grep -iF '' -m 1"
    begin
    tag = sh(git_cmd)
    rescue FastlaneCore::Interface::FastlaneShellError
    end
    tag
end